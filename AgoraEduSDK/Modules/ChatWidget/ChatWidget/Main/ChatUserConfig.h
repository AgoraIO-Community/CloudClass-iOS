//
//  ChatUserConfig.h
//  AgoraEducation
//
//  Created by lixiaoming on 2021/5/12.
//  Copyright © 2021 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatUserConfig : NSObject
@property (nonatomic,strong) NSString* username;
@property (nonatomic,strong) NSString* nickname;
@property (nonatomic,strong) NSString* avatarurl;
@property (nonatomic,strong) NSString* roomUuid;
@property (nonatomic) NSInteger role;
@end

NS_ASSUME_NONNULL_END
