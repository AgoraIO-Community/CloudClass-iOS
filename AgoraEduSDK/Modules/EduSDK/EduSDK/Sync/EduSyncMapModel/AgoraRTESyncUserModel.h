//
//  AgoraRTESyncUserModel.h
//  EduSDK
//
//  Created by SRS on 2020/8/31.
//

#import <Foundation/Foundation.h>
#import "AgoraRTESyncRoomSessionModel.h"
#import "AgoraRTEUser.h"
#import "AgoraRTESyncStreamModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTESyncUserModel : AgoraRTEBaseSnapshotUserModel

@property (nonatomic, strong) NSString *userToken;
@property (nonatomic, strong) NSString *streamUuid;
@property (nonatomic, assign) BOOL isChatAllowed;
@property (nonatomic, strong) NSDictionary *userProperties;
@property (nonatomic, strong) NSDictionary *cause;
@property (nonatomic, assign) NSInteger type;

@property (nonatomic, strong) AgoraRTEBaseUserModel * _Nullable operator;

- (AgoraRTEUser *)mapAgoraRTEUser;
- (AgoraRTEBaseUser *)mapAgoraRTEBaseUser;
- (AgoraRTELocalUser *)mapAgoraRTELocalUser;
- (AgoraRTEUserEvent *)mapAgoraRTEUserEvent;

@end

NS_ASSUME_NONNULL_END
