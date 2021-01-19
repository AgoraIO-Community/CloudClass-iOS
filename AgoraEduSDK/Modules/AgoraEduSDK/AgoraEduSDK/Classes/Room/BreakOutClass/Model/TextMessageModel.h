//
//  TextMessageModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/9/17.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TextMessageModel : NSObject
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *fromRoomUuid;
@property (nonatomic, strong) NSString *fromRoomName;
@property (nonatomic, assign) EduRoleType role;

@end

NS_ASSUME_NONNULL_END
