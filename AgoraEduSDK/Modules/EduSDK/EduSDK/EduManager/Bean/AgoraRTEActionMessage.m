//
//  AgoraRTEActionMessage.m
//  EduSDK
//
//  Created by SRS on 2020/9/24.
//

#import "AgoraRTEActionMessage.h"

@interface AgoraRTEActionMessage ()
@property (nonatomic, strong) NSString *processUuid;
@property (nonatomic, assign) AgoraRTEActionType action;
@property (nonatomic, assign) NSInteger timeout;
@property (nonatomic, strong) AgoraRTEBaseUser *fromUser;
@property (nonatomic, strong) NSDictionary *payload;
@end

@implementation AgoraRTEActionMessage

@end
