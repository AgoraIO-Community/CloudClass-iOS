//
//  AgoraRTEMsgAction.h
//  EduSDK
//
//  Created by SRS on 2020/9/24.
//

#import <Foundation/Foundation.h>
#import "AgoraRTESyncRoomSessionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEMsgAction : NSObject
@property (nonatomic, strong) NSString *processUuid;
@property (nonatomic, assign) NSInteger action;
@property (nonatomic, assign) NSInteger timeout;
@property (nonatomic, strong) AgoraRTEBaseUserModel *fromUser;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *payload;
@end

NS_ASSUME_NONNULL_END
