//
//  EduChannelMsgUsersProperty.h
//  AFNetworking
//
//  Created by SRS on 2020/9/17.
//

#import <Foundation/Foundation.h>
#import "EduSyncUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduChannelMsgUsersProperty : NSObject
@property (nonatomic, strong) BaseUserModel *fromUser;
@property (nonatomic, assign) NSInteger action;//1 upsert 2 delete
@property (nonatomic, strong) NSDictionary *changeProperties;
@property (nonatomic, strong) NSDictionary *cause;
//@property (nonatomic, strong) EduObject *operator;
@end

NS_ASSUME_NONNULL_END
