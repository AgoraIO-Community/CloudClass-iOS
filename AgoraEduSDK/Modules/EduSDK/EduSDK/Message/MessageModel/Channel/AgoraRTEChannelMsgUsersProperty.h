//
//  AgoraRTEChannelMsgUsersProperty.h
//  AFNetworking
//
//  Created by SRS on 2020/9/17.
//

#import <Foundation/Foundation.h>
#import "AgoraRTESyncUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEChannelMsgUsersProperty : NSObject
@property (nonatomic, strong) AgoraRTEBaseUserModel *fromUser;
@property (nonatomic, assign) NSInteger action;//1 upsert 2 delete
@property (nonatomic, strong) NSDictionary *changeProperties;
@property (nonatomic, strong) NSDictionary *cause;
@property (nonatomic, strong) AgoraRTEBaseUser *operator;
@end

NS_ASSUME_NONNULL_END
