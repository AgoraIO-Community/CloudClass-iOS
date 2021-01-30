//
//  AgoraRTEPublishModel.h
//  EduSDK
//
//  Created by SRS on 2020/7/28.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraRTEBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEPublishInfoModel : NSObject
@property (nonatomic, strong) NSString *streamUuid;
@property (nonatomic, strong) NSString *rtcToken;
@end

@interface AgoraRTEPublishModel : NSObject <AgoraRTEBaseModel>
@property (nonatomic, strong) AgoraRTEPublishInfoModel *data;
@end

NS_ASSUME_NONNULL_END
