//
//  AgoraRTESyncIncreaseModel.h
//  EduSDK
//
//  Created by SRS on 2020/9/1.
//

#import <Foundation/Foundation.h>
#import "AgoraRTEBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTESyncIncreaseDataModel : NSObject
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) NSInteger nextId;
@property (nonatomic, strong) NSArray *list;
@end

@interface AgoraRTESyncIncreaseModel : NSObject <AgoraRTEBaseModel>
@property (nonatomic, strong) AgoraRTESyncIncreaseDataModel *data;
@end

NS_ASSUME_NONNULL_END
