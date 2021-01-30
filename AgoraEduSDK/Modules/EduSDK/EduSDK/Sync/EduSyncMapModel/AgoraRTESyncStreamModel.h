//
//  AgoraRTESyncStreamModel.h
//  EduSDK
//
//  Created by SRS on 2020/8/31.
//

#import <Foundation/Foundation.h>
#import "AgoraRTESyncRoomSessionModel.h"
#import "AgoraRTEStream.h"

typedef NS_ENUM(NSInteger, AgoraRTEAudioSourceType) {
    AgoraRTEAudioSourceTypeNone = 0,
    AgoraRTEAudioSourceTypeMicr = 1,
};

NS_ASSUME_NONNULL_BEGIN

@interface AgoraRTESyncStreamModel : AgoraRTEBaseSnapshotStreamModel

@property (nonatomic, strong) NSString *streamName;
@property (nonatomic, assign) NSInteger videoSourceType; // 0.none 1.camera 2.screen
@property (nonatomic, assign) NSInteger audioSourceType; // 0.none 1.mic
@property (nonatomic, assign) NSInteger videoState; // 0=关 1=开 2=禁
@property (nonatomic, assign) NSInteger audioState; // 0=关 1=开 2=禁
@property (nonatomic, assign) NSInteger updateTime;

@property (nonatomic, strong) AgoraRTEBaseUserModel * _Nullable operator;

- (AgoraRTEStream *)mapAgoraRTEStream;

- (AgoraRTEStreamEvent *)mapAgoraRTEStreamEvent;

@end

NS_ASSUME_NONNULL_END
