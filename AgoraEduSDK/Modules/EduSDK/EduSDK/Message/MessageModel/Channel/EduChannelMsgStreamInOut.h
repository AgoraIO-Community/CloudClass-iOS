//
//  EduChannelMsgStreamInOut.h
//  EduSDK
//
//  Created by SRS on 2020/7/26.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EduSyncStreamModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface EduChannelMsgStreamInOut : EduSyncStreamModel
@property (nonatomic, assign) NSInteger action; // 1.add 2.upsert 3.remove
@end

@interface EduChannelMsgStreamsInOut : EduSyncStreamModel
@property (nonatomic, strong) NSArray<EduChannelMsgStreamInOut *> *streams;
@property (nonatomic, strong) BaseUserModel * _Nullable operator;
@end


NS_ASSUME_NONNULL_END
