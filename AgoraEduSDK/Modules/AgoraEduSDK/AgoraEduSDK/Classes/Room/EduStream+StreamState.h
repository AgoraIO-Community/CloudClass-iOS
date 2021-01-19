//
//  EduStream+StreamState.h
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/9.
//

#import <EduSDK/EduSDK.h>

typedef NS_ENUM(NSUInteger, EduRtcStreamState) {
    EduRtcStreamStateNormal = 0,
    EduRtcStreamStateAbnormal = 1,
};

NS_ASSUME_NONNULL_BEGIN

@interface EduStream (StreamState)
@property (assign, nonatomic) EduRtcStreamState video;
@property (assign, nonatomic) EduRtcStreamState audio;
@end

NS_ASSUME_NONNULL_END
