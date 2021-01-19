//
//  EduSyncStreamModel.h
//  EduSDK
//
//  Created by SRS on 2020/8/31.
//

#import <Foundation/Foundation.h>
#import "SyncRoomSessionModel.h"
#import "EduStream.h"

typedef NS_ENUM(NSInteger, EduAudioSourceType) {
    EduAudioSourceTypeNone = 0,
    EduAudioSourceTypeMicr = 1,
};

NS_ASSUME_NONNULL_BEGIN

@interface EduSyncStreamModel : BaseSnapshotStreamModel

@property (nonatomic, strong) NSString *streamName;
@property (nonatomic, assign) NSInteger videoSourceType; // 0.none 1.camera 2.screen
@property (nonatomic, assign) NSInteger audioSourceType; // 0.none 1.mic
@property (nonatomic, assign) NSInteger videoState; // 0=关 1=开 2=禁
@property (nonatomic, assign) NSInteger audioState; // 0=关 1=开 2=禁
@property (nonatomic, assign) NSInteger updateTime;

@property (nonatomic, strong) BaseUserModel * _Nullable operator;

- (EduStream *)mapEduStream;

- (EduStreamEvent *)mapEduStreamEvent;

@end

NS_ASSUME_NONNULL_END
