//
//  AgoraRTEChannelMsgStreamInOut.h
//  EduSDK
//
//  Created by SRS on 2020/7/26.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraRTESyncStreamModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTEChannelMsgStreamInOut : AgoraRTESyncStreamModel
@property (nonatomic, assign) NSInteger action; // 1.add 2.upsert 3.remove
@end

@interface AgoraRTEChannelMsgStreamsInOut : AgoraRTESyncStreamModel
@property (nonatomic, strong) NSArray<AgoraRTEChannelMsgStreamInOut *> *streams;
@property (nonatomic, strong) AgoraRTEBaseUserModel * _Nullable operator;
@end


NS_ASSUME_NONNULL_END
