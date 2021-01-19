//
//  EduActionMessage.h
//  EduSDK
//
//  Created by SRS on 2020/9/24.
//

#import <Foundation/Foundation.h>
#import "EduEnumerates.h"
#import "EduUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduActionMessage : NSObject
@property (nonatomic, strong, readonly) NSString *processUuid;
@property (nonatomic, assign, readonly) EduActionType action;
@property (nonatomic, assign, readonly) NSInteger timeout;
@property (nonatomic, strong, readonly) EduBaseUser *fromUser;
@property (nonatomic, strong, readonly) NSDictionary *payload;
@end

NS_ASSUME_NONNULL_END
