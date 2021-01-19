//
//  AgoraEduReplay.h
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AgoraEduReplay;
@protocol AgoraEduReplayDelegate <NSObject>
@optional
- (void)replay:(AgoraEduReplay *)replay didReceivedEvent:(AgoraEduEvent)event;
@end

@interface AgoraEduReplay : NSObject

- (void)destory;

@end

NS_ASSUME_NONNULL_END
