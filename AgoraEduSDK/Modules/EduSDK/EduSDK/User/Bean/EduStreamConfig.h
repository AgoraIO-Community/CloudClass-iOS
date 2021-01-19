//
//  EduStreamConfig.h
//  Demo
//
//  Created by SRS on 2020/6/24.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EduEnumerates.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduSubscribeOptions : NSObject
@property (nonatomic, assign) BOOL subscribeAudio;
@property (nonatomic, assign) BOOL subscribeVideo;
@property (nonatomic, assign) EduVideoStreamType videoStreamType;
@end

@interface EduStreamConfig : NSObject

@property (nonatomic, copy) NSString *streamUuid;
@property (nonatomic, copy) NSString *streamName;

@property (nonatomic, assign) BOOL enableCamera;
@property (nonatomic, assign) BOOL enableMicrophone;

- (instancetype)initWithStreamUuid:(NSString *)streamUuid;

@end

NS_ASSUME_NONNULL_END
