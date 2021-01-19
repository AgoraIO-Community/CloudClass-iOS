//
//  AgoraEduClassroom.h
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/9.
//

#import <Foundation/Foundation.h>
#import "AgoraEduEnums.h"

NS_ASSUME_NONNULL_BEGIN

@class AgoraEduClassroom;
@protocol AgoraEduClassroomDelegate <NSObject>
@optional
- (void)classroom:(AgoraEduClassroom *)classroom didReceivedEvent:(AgoraEduEvent)event;
@end

@interface AgoraEduClassroom : NSObject

- (void)destory;

@end

NS_ASSUME_NONNULL_END
