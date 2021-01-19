//
//  ReplayConfiguration.h
//  AgoraReplay
//
//  Created by SRS on 2020/7/20.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BoardConfiguration : NSObject

@property (nonatomic, copy) NSString *boardAppid;
@property (nonatomic, copy) NSString *boardId;
@property (nonatomic, copy) NSString *boardToken;

@end

@interface VideoConfiguration : NSObject

@property (nonatomic, copy) NSString *urlString;

@end


@interface ReplayConfiguration : NSObject

// millisecond
@property (nonatomic, copy) NSString *startTime;
// millisecond
@property (nonatomic, copy) NSString *endTime;

@property (nonatomic, strong) BoardConfiguration *boardConfig;
@property (nonatomic, strong) VideoConfiguration *videoConfig;

@end

NS_ASSUME_NONNULL_END
