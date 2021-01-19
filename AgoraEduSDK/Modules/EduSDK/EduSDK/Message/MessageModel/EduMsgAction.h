//
//  EduMsgAction.h
//  EduSDK
//
//  Created by SRS on 2020/9/24.
//

#import <Foundation/Foundation.h>
#import "SyncRoomSessionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduMsgAction : NSObject
@property (nonatomic, strong) NSString *processUuid;
@property (nonatomic, assign) NSInteger action;
@property (nonatomic, assign) NSInteger timeout;
@property (nonatomic, strong) BaseUserModel *fromUser;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *payload;
@end

NS_ASSUME_NONNULL_END
