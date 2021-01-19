//
//  EduActionMessage.m
//  EduSDK
//
//  Created by SRS on 2020/9/24.
//

#import "EduActionMessage.h"

@interface EduActionMessage ()
@property (nonatomic, strong) NSString *processUuid;
@property (nonatomic, assign) EduActionType action;
@property (nonatomic, assign) NSInteger timeout;
@property (nonatomic, strong) EduBaseUser *fromUser;
@property (nonatomic, strong) NSDictionary *payload;
@end

@implementation EduActionMessage

@end
