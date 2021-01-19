//
//  EETextMessage.h
//  AgoraEducation
//
//  Created by SRS on 2020/8/3.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EETextMessage : NSObject
@property (nonatomic, strong) EduUser *fromUser;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) NSInteger timestamp;

@property (nonatomic, strong) NSString *recordRoomUuid;
@property (nonatomic, assign) CGFloat cellHeight;
@end

NS_ASSUME_NONNULL_END
