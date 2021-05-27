//
//  AgoraEduReplayConfiguration.h
//  AgoraReplay
//
//  Created by SRS on 2020/7/20.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AgoraEduBoardConfiguration : NSObject
@property (nonatomic, copy) NSString *boardAppid;
@property (nonatomic, copy) NSString *boardId;
@property (nonatomic, copy) NSString *boardToken;
@end

@interface AgoraEduVideoConfiguration : NSObject
@property (nonatomic, copy) NSString *urlString;
@end


@interface AgoraEduReplayConfiguration : NSObject
// millisecond
@property (nonatomic, copy) NSString *startTime;
// millisecond
@property (nonatomic, copy) NSString *endTime;

@property (nonatomic, strong) AgoraEduBoardConfiguration *boardConfig;
@property (nonatomic, strong) AgoraEduVideoConfiguration *videoConfig;
@end

NS_ASSUME_NONNULL_END
