//
//  SyncRoomSession.m
//  EduSDK
//
//  Created by SRS on 2020/8/25.
//

#import "SyncRoomSession.h"
#import <YYModel/YYModel.h>
#import <stdatomic.h>
#import "AgoraLogService.h"
#import <UIKit/UIKit.h>

#define NoNullNumber(x) ([x isKindOfClass:NSNumber.class]) ? x : @0)
#define NoNullString(x) ([x isKindOfClass:NSString.class] ? x : @"")
#define NoNullArray(x) ([x isKindOfClass:NSArray.class] ? x : @[])
#define NoNullDictionary(x) ([x isKindOfClass:NSDictionary.class] ? x : @{})
#define NoNull(x) ((x == nil) ? @"nil" : x)

// 等待RTM500毫秒
#define RTM_SYNC_DELAY 500

@interface StreamModifyModel : NSObject
@property(nonatomic, strong) NSMutableArray<BaseSnapshotStreamModel *> *localRemoveStreams;
@property(nonatomic, strong) NSMutableArray<BaseSnapshotStreamModel *> *remoteRemoveStreams;
@property(nonatomic, strong) NSMutableArray<BaseSnapshotStreamModel *> *localAddStreams;
@property(nonatomic, strong) NSMutableArray<BaseSnapshotStreamModel *> *remoteAddStreams;
@property(nonatomic, strong) NSMutableArray<BaseSnapshotStreamModel *> *localFromUpdateStreams;
@property(nonatomic, strong) NSMutableArray<BaseSnapshotStreamModel *> *localToUpdateStreams;
@property(nonatomic, strong) NSMutableArray<BaseSnapshotStreamModel *> *remoteFromUpdateStreams;
@property(nonatomic, strong) NSMutableArray<BaseSnapshotStreamModel *> *remoteToUpdateStreams;
@end
@implementation StreamModifyModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.localRemoveStreams = [NSMutableArray array];
        self.remoteRemoveStreams = [NSMutableArray array];
        self.localAddStreams = [NSMutableArray array];
        self.remoteAddStreams = [NSMutableArray array];
        self.localFromUpdateStreams = [NSMutableArray array];
        self.localToUpdateStreams = [NSMutableArray array];
        self.remoteFromUpdateStreams = [NSMutableArray array];
        self.remoteToUpdateStreams = [NSMutableArray array];
    }
    return self;
}
@end


/// Global display queue, used for content rendering.
static dispatch_queue_t AgoraAsyncGetDisplayQueue() {
#define MAX_QUEUE_COUNT 16
    static int queueCount;
    static dispatch_queue_t queues[MAX_QUEUE_COUNT];
    static dispatch_once_t onceToken;
    static atomic_int counter = 0;
    dispatch_once(&onceToken, ^{
        queueCount = (int)[NSProcessInfo processInfo].activeProcessorCount;
        queueCount = queueCount < 1 ? 1 : queueCount > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : queueCount;
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            for (NSUInteger i = 0; i < queueCount; i++) {
                dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0);
                queues[i] = dispatch_queue_create("com.agora.sync", attr);
            }
        } else {
            for (NSUInteger i = 0; i < queueCount; i++) {
                queues[i] = dispatch_queue_create("com.agora.sync", DISPATCH_QUEUE_SERIAL);
                dispatch_set_target_queue(queues[i], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
            }
        }
    });

    int cur = atomic_fetch_add(&counter, 1);;
    if (cur < 0) cur = -cur;
    return queues[(cur) % queueCount];
#undef MAX_QUEUE_COUNT
}
static dispatch_queue_t AgoraAsyncGetReleaseQueue() {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}

@interface SyncRoomSession<RoomT: BaseSnapshotRoomModel *,
                            UserT: BaseSnapshotUserModel *,
                            StreamT : BaseSnapshotStreamModel *> ()

@property (nonatomic, assign) NSInteger currentMaxSeq;

@property (nonatomic, strong) NSString *userUuid;
@property (nonatomic, strong) Class roomClass;
@property (nonatomic, strong) Class userClass;
@property (nonatomic, strong) Class streamClass;

@property (nonatomic, strong) NSMutableArray<CacheRoomSessionModel*> *cacheRoomSessionModels;
@property (nonatomic, strong) NSMutableArray *localStreams;

@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation SyncRoomSession

- (instancetype)initWithUserUuid:(NSString *)userUuid roomClass:(Class)roomClass useClass:(Class)userClass streamClass:(Class)streamClass {
    
    if(self = [super init]) {
        self.currentMaxSeq = -1;
        self.userUuid = userUuid;
    
        NSAssert([[roomClass alloc] isKindOfClass:BaseSnapshotRoomModel.class], @"roomClass should kind of class BaseSnapshotRoomModel");
        NSAssert([[userClass alloc] isKindOfClass:BaseSnapshotUserModel.class], @"userClass should kind of class BaseSnapshotUserModel");
        NSAssert([[streamClass alloc] isKindOfClass:BaseSnapshotStreamModel.class], @"streamClass should kind of class BaseSnapshotStreamModel");

        self.roomClass = roomClass;
        self.userClass = userClass;
        self.streamClass = streamClass;
        
        self.cacheRoomSessionModels = [NSMutableArray array];
        self.localStreams = [NSMutableArray array];
        self.users = [NSMutableArray array];
        self.streams = [NSMutableArray array];
        
        self.queue = AgoraAsyncGetDisplayQueue();
    }
    return self;
}

- (void)syncSnapshot:(NSDictionary *)syncData complete:(void (^) (void))block {
    dispatch_async(self.queue, ^{
        [self _syncSnapshot:syncData complete:block];
    });
}
- (void)_syncSnapshot:(NSDictionary *)syncData complete:(void (^) (void))block {
    
    self.currentMaxSeq = -1;
    [self.localStreams removeAllObjects];
    [self.users removeAllObjects];
    [self.streams removeAllObjects];

    for (id obj in self.localUser.streams) {
        id streamObj = [obj yy_modelToJSONObject];
        BaseSnapshotStreamModel *stream = [self.streamClass new];
        [stream yy_modelSetWithJSON: streamObj];
        
        BaseUserModel *_fromUser = [BaseUserModel new];
        _fromUser.role = self.localUser.role;
        _fromUser.userName = self.localUser.userName;
        _fromUser.userUuid = self.localUser.userUuid;
        stream.fromUser = _fromUser;
        
        [self.localStreams addObject: stream];
        [self.streams addObject: stream];
    }
    self.localUser.streams = self.localStreams;
    [self.users addObject:self.localUser];
    
    RoomSessionDataModel *model = [RoomSessionDataModel yy_modelWithDictionary:syncData];
    self.currentMaxSeq = model.sequence;
    
    self.room = [self.roomClass yy_modelWithDictionary:model.snapshot.room];
    
    NSMutableArray *users = [NSMutableArray array];
    NSMutableArray *streams = [NSMutableArray array];
    if (model.snapshot.users != nil) {
        for (NSDictionary *userDic in model.snapshot.users) {
            BaseSnapshotUserModel *user = [self.userClass yy_modelWithDictionary:userDic];
            if ([user.userUuid isEqualToString:self.localUser.userUuid]) {
                continue;
            }
            [users addObject:user];

            for(BaseSnapshotStreamModel *stream in user.streams) {
                BaseUserModel *_fromUser = [BaseUserModel new];
                _fromUser.role = user.role;
                _fromUser.userName = user.userName;
                _fromUser.userUuid = user.userUuid;
                stream.fromUser = _fromUser;
                [streams addObject:stream];
            }
        }
    }

    [self.users addObjectsFromArray:users];
    [self.streams addObjectsFromArray:streams];
 
    if (block != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    }

    if ([self.delegate respondsToSelector:@selector(onRemoteUserInit:)]) {
        
        NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"userUuid != %@", self.userUuid];
        NSArray *userFilters = [self.users filteredArrayUsingPredicate:userPredicate];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (userFilters.count > 0) {
                [self.delegate onRemoteUserInit:userFilters];
            }
        });
    }
    if ([self.delegate respondsToSelector:@selector(onRemoteStreamInit:)]) {
            
        NSPredicate *streamPredicate = [NSPredicate predicateWithFormat:@"fromUser.userUuid != %@", self.userUuid];
        NSArray *streamFilters = [self.streams filteredArrayUsingPredicate:streamPredicate];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (streamFilters.count > 0) {
                [self.delegate onRemoteStreamInit:streamFilters];
            }
        });
    }
    if ([self.delegate respondsToSelector:@selector(onLocalStreamInit:)]) {

        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.localStreams.count > 0) {
                [self.delegate onLocalStreamInit:self.localStreams];
            }
        });
    }
    
    [self checkCacheRoomSession];
}

- (void)updateRoom:(id)room sequence:(NSInteger)sequence cause:(NSDictionary * _Nullable )cause {
    dispatch_async(self.queue, ^{
        [self _updateRoom:room sequence:sequence cause:cause];
    });
}
- (void)_updateRoom:(id)room sequence:(NSInteger)sequence cause:(NSDictionary *)cause {
        
    if(sequence <= self.currentMaxSeq){
        return;
    }
    
    [AgoraLogService logMessageWithDescribe:@"sync updateRoom:" message:@{@"room":NoNull(room), @"cause":NoNull(cause), @"sequence":@(sequence), @"currentMaxSeq":@(self.currentMaxSeq)}];

    NSInteger gap = sequence - self.currentMaxSeq;
    if (gap == 1 && self.currentMaxSeq != -1) {
        self.currentMaxSeq = sequence;
        if (room == nil || ![room isKindOfClass:self.roomClass]) {
            [self checkCacheRoomSession];
            return;
        }
        
        BaseSnapshotRoomModel *originalRoom = [self.roomClass new];
        id obj = [self.room yy_modelToJSONObject];
        [originalRoom yy_modelSetWithJSON:obj];

        self.room = room;
        if ([self.delegate respondsToSelector:@selector(onRoomUpdateFrom:to:cause:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate onRoomUpdateFrom:originalRoom to:self.room cause:cause];
            });
        }
        [self checkCacheRoomSession];
        
    } else {
        [self insertCacheWithSeq:sequence value:NoNull(room) cause:cause];

        // 延时处理请求
        [self handelFetchMessageListStart:self.currentMaxSeq + 1 count:sequence - self.currentMaxSeq - 1];
    }
}

- (void)updateUser:(NSArray *)users sequence:(NSInteger)sequence {
    dispatch_async(self.queue, ^{
        [self _updateUser:users sequence:sequence];
    });
}

- (void)_updateUser:(NSArray *)users sequence:(NSInteger)sequence {
        
    if (sequence <= self.currentMaxSeq) {
        return;
    }
    
    [AgoraLogService logMessageWithDescribe:@"sync updateUser:" message:@{@"room":NoNull(self.room), @"users":NoNull(users), @"sequence":@(sequence), @"currentMaxSeq":@(self.currentMaxSeq)}];

    NSInteger gap = sequence - self.currentMaxSeq;
    if (gap == 1 && self.currentMaxSeq != -1) {
        self.currentMaxSeq = sequence;
        if (users == nil || users.count == 0 || ![users.firstObject isKindOfClass:self.userClass]) {
            [self checkCacheRoomSession];
            return;
        }
        
        for(BaseSnapshotUserModel *userModel in users) {

            NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"userUuid = %@", userModel.userUuid];
            NSArray *userFilters = [self.users filteredArrayUsingPredicate:userPredicate];
            
            if(userFilters.count > 0) {
                BaseSnapshotUserModel *filterUser = userFilters.firstObject;
                
                NSPredicate *streamPredicate = [NSPredicate predicateWithFormat:@"fromUser.userUuid = %@", NoNull(filterUser.userUuid)];
                NSArray *streamFilters = [self.streams filteredArrayUsingPredicate:streamPredicate];
                
                if (userModel.state == 0) {
                    [self.streams removeObjectsInArray:streamFilters];
                    if (streamFilters.count > 0 && [userModel.userUuid isEqualToString:self.userUuid]) {
                        [self.localStreams removeObjectsInArray:streamFilters];
                        
                        if ([self.delegate respondsToSelector:@selector(onLocalStreamInOut:state:)]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (streamFilters.count > 0) {
                                    [self.delegate onLocalStreamInOut:streamFilters state:SessionStateDelete];
                                }
                            });
                        }
                    } else {
                        if ([self.delegate respondsToSelector:@selector(onRemoteStreamInOut:state:)]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (streamFilters.count > 0) {
                                    [self.delegate onRemoteStreamInOut:streamFilters state:SessionStateDelete];
                                }
                            });
                        }
                    }
                    
                    [self.users removeObjectsInArray:userFilters];
                    if([userModel.userUuid isEqualToString:self.userUuid]) {
                        if ([self.delegate respondsToSelector:@selector(onLocalUserInOut:state:)]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.delegate onLocalUserInOut:userModel state:SessionStateDelete];
                            });
                        }
                    } else {
                        if ([self.delegate respondsToSelector:@selector(onRemoteUserInOut:state:)]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.delegate onRemoteUserInOut:@[userModel] state:SessionStateDelete];
                            });
                        }
                    }
                } else if (userModel.state == 1) {
                    // update
                    BaseSnapshotUserModel *originalObj = [self.userClass new];
                    id obj = [filterUser yy_modelToJSONObject];
                    [originalObj yy_modelSetWithJSON:obj];

                    id userObj = [userModel yy_modelToJSONObject];
                    [filterUser yy_modelSetWithJSON:userObj];

                    if ([userModel.userUuid isEqualToString:self.userUuid]) {
                        
                        [self.localUser yy_modelSetWithJSON: userObj];

                        if ([self.delegate respondsToSelector:@selector(onLocalUserUpdateFrom:to:)]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.delegate onLocalUserUpdateFrom:originalObj to:filterUser];
                            });
                        }
                    } else {
                        if ([self.delegate respondsToSelector:@selector(onRemoteUserUpdateFrom:to:)]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.delegate onRemoteUserUpdateFrom:originalObj to:filterUser];
                            });
                        }
                    }
                }
            } else if (userModel.state == 1) {// 没有当前的人
                [self.users addObject:userModel];
                if (NoNullArray(userModel.streams).count > 0) {
                    if([userModel.userUuid isEqualToString:self.userUuid]) {
                        [self.localStreams removeAllObjects];
                        
                        // update local user
                        id userObj = [userModel yy_modelToJSONObject];
                        [self.localUser yy_modelSetWithJSON:userObj];
                    }
                    
                    for(BaseSnapshotStreamModel *streamModel in userModel.streams) {
                        
                        NSPredicate *streamPredicate = [NSPredicate predicateWithFormat:@"streamUuid = %@", streamModel.streamUuid];
                        NSArray *streamFilters = [self.streams filteredArrayUsingPredicate:streamPredicate];
                        [self.streams removeObjectsInArray:streamFilters];
                        
                        BaseUserModel *_fromUser = [BaseUserModel new];
                        _fromUser.role = userModel.role;
                        _fromUser.userName = userModel.userName;
                        _fromUser.userUuid = userModel.userUuid;
                        streamModel.fromUser = _fromUser;
                        [self.streams addObject:streamModel];
                        
                        if([userModel.userUuid isEqualToString:self.userUuid]) {
                            [self.localStreams addObject:streamModel];
                        }
                    }
                }
            
                if([userModel.userUuid isEqualToString:self.userUuid]) {
                    
                    if ([self.delegate respondsToSelector:@selector(onLocalUserInOut:state:)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate onLocalUserInOut:userModel state:SessionStateCreate];
                        });
                    }
                    
                    if ([self.delegate respondsToSelector:@selector(onLocalStreamInit:)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (NoNullArray(userModel.streams).count > 0) {
                                [self.delegate onLocalStreamInit:userModel.streams];
                            }
                        });
                    }
                    
                } else {
                    if ([self.delegate respondsToSelector:@selector(onRemoteUserInOut:state:)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate onRemoteUserInOut:@[userModel] state:SessionStateCreate];
                        });
                    }
                    
                    if ([self.delegate respondsToSelector:@selector(onLocalStreamInit:)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (NoNullArray(userModel.streams).count > 0) {
                                [self.delegate onRemoteStreamInit:userModel.streams];
                            }
                        });
                    }
                }
            }
        }
    
        [self checkCacheRoomSession];
    } else {
        [self insertCacheWithSeq:sequence value:NoNull(users)];
        
        // 延时处理请求
        [self handelFetchMessageListStart:self.currentMaxSeq + 1 count:sequence - self.currentMaxSeq - 1];
    }
}

- (void)updateStream:(NSArray *)streams sequence:(NSInteger)sequence {
    dispatch_async(self.queue, ^{
        [self _updateStream:streams sequence:sequence];
    });
}
- (void)_updateStream:(NSArray *)streams sequence:(NSInteger)sequence {
    if (sequence <= self.currentMaxSeq) {
        return;
    }

    [AgoraLogService logMessageWithDescribe:@"sync updateStream:" message:@{@"room":NoNull(self.room), @"streams":NoNull(streams), @"sequence":@(sequence), @"currentMaxSeq":@(self.currentMaxSeq)}];

    NSInteger gap = sequence - self.currentMaxSeq;
    if (gap == 1 && self.currentMaxSeq != -1) {
        
        self.currentMaxSeq = sequence;
        
        if (streams == nil || streams.count == 0 || ![streams.firstObject isKindOfClass:self.streamClass]) {
            [self checkCacheRoomSession];
            return;
        }
        
        StreamModifyModel *streamModifyModel = [[StreamModifyModel alloc] init];
        
        for (BaseSnapshotStreamModel *streamModel in streams) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamUuid = %@", streamModel.streamUuid];
            NSArray *filters = [self.streams filteredArrayUsingPredicate:predicate];
            
            if(filters.count > 0) {
                BaseSnapshotStreamModel *filterStream = filters.firstObject;
                if (streamModel.state == 0) {
                    [self.streams removeObjectsInArray:filters];
                    if ([filterStream.fromUser.userUuid isEqualToString:self.userUuid]) {
                        [self.localStreams removeObjectsInArray:filters];
                        [streamModifyModel.localRemoveStreams addObjectsFromArray:filters];
                    } else {
                        [streamModifyModel.remoteRemoveStreams addObjectsFromArray:filters];
                    }

                } else if (streamModel.state == 1) {
                    // update
                    BaseSnapshotStreamModel *originalObj = [self.streamClass new];
                    id obj = [filterStream yy_modelToJSONObject];
                    [originalObj yy_modelSetWithJSON:obj];

                    id streamObj = [streamModel yy_modelToJSONObject];
                    [filterStream yy_modelSetWithJSON:streamObj];

                    if ([filterStream.fromUser.userUuid isEqualToString:self.userUuid]) {
                        
                        for(BaseSnapshotStreamModel *streamModel in self.localUser.streams) {
                            if([streamModel.streamUuid isEqualToString:filterStream.streamUuid]) {
                                [streamModel yy_modelSetWithJSON: filterStream];
                            }
                        }
                        [streamModifyModel.localFromUpdateStreams addObject:originalObj];
                        [streamModifyModel.localToUpdateStreams addObject:filterStream];
                    } else {
                        [streamModifyModel.remoteFromUpdateStreams addObject:originalObj];
                        [streamModifyModel.remoteToUpdateStreams addObject:filterStream];
                    }
                }
            } else if (streamModel.state == 1) {
                [self.streams addObject:streamModel];
                if ([streamModel.fromUser.userUuid isEqualToString:self.userUuid]) {
                    [self.localStreams addObject:streamModel];
                    [streamModifyModel.localAddStreams addObject:streamModel];
                } else {
                    [streamModifyModel.remoteAddStreams addObject:streamModel];
                }
            }
        }

        [self callStreamsDelegate:streamModifyModel];
        
        [self checkCacheRoomSession];
    } else {
        [self insertCacheWithSeq:sequence value:NoNull(streams)];

        // 延时处理请求
        [self handelFetchMessageListStart:self.currentMaxSeq + 1 count:sequence - self.currentMaxSeq - 1];
    }
}

- (void)callStreamsDelegate:(StreamModifyModel *)streamModifyModel {
    
    if ([self.delegate respondsToSelector:@selector(onLocalStreamInOut:state:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(streamModifyModel.localRemoveStreams.count > 0){
                [self.delegate onLocalStreamInOut:streamModifyModel.localRemoveStreams state:SessionStateDelete];
                
            } else if(streamModifyModel.localAddStreams.count > 0){
                [self.delegate onLocalStreamInOut:streamModifyModel.localAddStreams state:SessionStateCreate];
            }
        });
    }
   
    if ([self.delegate respondsToSelector:@selector(onRemoteStreamInOut:state:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(streamModifyModel.remoteRemoveStreams.count > 0){
                [self.delegate onRemoteStreamInOut:streamModifyModel.remoteRemoveStreams state:SessionStateDelete];
                
            } else if(streamModifyModel.remoteAddStreams.count > 0){
                [self.delegate onRemoteStreamInOut:streamModifyModel.remoteAddStreams state:SessionStateCreate];
            }
        });
    }
   
    if ([self.delegate respondsToSelector:@selector(onLocalStreamUpdateFrom:to:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(streamModifyModel.localFromUpdateStreams.count > 0){
                [self.delegate onLocalStreamUpdateFrom:streamModifyModel.localFromUpdateStreams to:streamModifyModel.localToUpdateStreams];
            }
        });
    }
    
    if ([self.delegate respondsToSelector:@selector(onRemoteStreamUpdateFrom:to:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(streamModifyModel.remoteFromUpdateStreams.count > 0){
                [self.delegate onRemoteStreamUpdateFrom:streamModifyModel.remoteFromUpdateStreams to:streamModifyModel.remoteToUpdateStreams];
            }
        });
    }
}

- (void)updateOther:(id)value sequence:(NSInteger)sequence {
    dispatch_async(self.queue, ^{
        [self _updateOther:value sequence:sequence];
    });
}
- (void)_updateOther:(id)value sequence:(NSInteger)sequence {
        
    if(sequence <= self.currentMaxSeq){
        return;
    }
    
    [AgoraLogService logMessageWithDescribe:@"sync updateOther:" message:@{@"room":NoNull(self.room), @"value":NoNull(value), @"sequence":@(sequence), @"currentMaxSeq":@(self.currentMaxSeq)}];
    
    NSInteger gap = sequence - self.currentMaxSeq;
    if (gap == 1 && self.currentMaxSeq != -1) {
        
        self.currentMaxSeq = sequence;
        if (value == nil) {
            [self checkCacheRoomSession];
            return;
        }
        
        if ([self.delegate respondsToSelector:@selector(onOtherUpdate:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate onOtherUpdate:value];
            });
        }
        [self checkCacheRoomSession];
    } else {
        [self insertCacheWithSeq:sequence value:value];
    
        // 延时处理请求
        [self handelFetchMessageListStart:self.currentMaxSeq + 1 count:sequence - self.currentMaxSeq - 1];
    }
}

#pragma mark --PRIVATE
- (void)setCurrentMaxSeq:(NSInteger)currentMaxSeq {
    _currentMaxSeq = currentMaxSeq;
    [AgoraLogService logMessageWithDescribe:@"sync currentMaxSeq:" message:@(currentMaxSeq)];
}
- (void)insertCacheWithSeq:(NSInteger)sequence value:(NSArray *)value cause:(NSDictionary *)cause {
    
    CacheRoomSessionModel *cache = [CacheRoomSessionModel new];
    cache.sequence = sequence;
    cache.value = value;
    cache.cause = cause;
    NSInteger index = 0;
    if (self.cacheRoomSessionModels.count == 0) {
        [self.cacheRoomSessionModels addObject:cache];
        
    } else {
        for(CacheRoomSessionModel *model in self.cacheRoomSessionModels) {
            index++;
            if(model.sequence <= sequence) {
                continue;
            } else {
                [self.cacheRoomSessionModels insertObject:cache atIndex:index];
                break;
            }
        }
    }
 
    [AgoraLogService logMessageWithDescribe:@"sync insertCacheWithSeq:" message:@(sequence)];
}
- (void)insertCacheWithSeq:(NSInteger)sequence value:(NSArray *)value {
    [self insertCacheWithSeq:sequence value:value cause:nil];
}

- (void)checkCacheRoomSession {
    NSMutableArray *rmvModel = [NSMutableArray array];
    for(CacheRoomSessionModel *model in self.cacheRoomSessionModels) {
        NSInteger gap = model.sequence - self.currentMaxSeq;
        [AgoraLogService logMessageWithDescribe:@"sync checkCacheRoomSession:" message:@{@"room":NoNull(self.room), @"value":NoNull(model), @"sequence":@(model.sequence), @"currentMaxSeq":@(self.currentMaxSeq)}];
        if (gap == 1) {
            [rmvModel addObject:model];
            if ([model.value isKindOfClass:self.roomClass]) {
                // update room
                [self updateRoom:model.value sequence:model.sequence cause:model.cause];
                
            } else if ([model.value isKindOfClass:self.userClass]) {
                // update user
                [self updateUser:@[model.value] sequence:model.sequence];
                
            } else if ([model.value isKindOfClass:self.streamClass]) {
                // update stream
                [self updateStream:@[model.value] sequence:model.sequence];
                
            } else if ([model.value isKindOfClass: NSArray.class]) {
                // 是数据进入的
                if([[model.value firstObject] isKindOfClass: self.userClass]) {
                    [self updateUser:model.value sequence:model.sequence];
                    
                } else if([[model.value firstObject] isKindOfClass: self.streamClass]) {
                    [self updateStream:model.value sequence:model.sequence];
                } else {
                    NSAssert("1 != 1", @"model.value error");
                }

            } else {
                if ([self.delegate respondsToSelector:@selector(onOtherUpdate:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate onOtherUpdate:model.value];
                    });
                }
            }
        } else if(gap <= 0) {
            [rmvModel addObject:model];
        } else {
            break;
        }
    }
    [self.cacheRoomSessionModels removeObjectsInArray:rmvModel];
}

- (void)handelFetchMessageListStart:(NSInteger)nextId count:(NSInteger)count {
    //  如果同步没有完成，等待同步完成。 不做增量更新
    if (self.currentMaxSeq == -1) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.fetchMessageList(nextId, count);
    });
}

#pragma mark --get Queue
- (void)getStreamsInQueue:(void (^) (NSArray *))block {
    dispatch_async(self.queue, ^{
        block(self.streams);
    });
}
- (void)getUsersInQueue:(void (^) (NSArray *))block {
    dispatch_async(self.queue, ^{
        block(self.users);
    });
}
- (void)getRoomInQueue:(void (^) (BaseSnapshotRoomModel *))block {
    dispatch_async(self.queue, ^{
        block(self.room);
    });
}

- (void)dealloc {
    [AgoraLogService logMessageWithDescribe:@"SyncRoomSession dealloc:" message:@{@"room":NoNull(self.room)}];
}

@end
