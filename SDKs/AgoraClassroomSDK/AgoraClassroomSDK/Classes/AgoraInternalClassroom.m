//
//  AgoraInternalClassroom.m
//  AgoraClassroomSDK
//
//  Created by Cavan on 2021/6/30.
//  Copyright © 2021 Agora. All rights reserved.
//

#import "AgoraInternalClassroom.h"
#import "AgoraEduEnums.h"

@implementation AgoraClassroomSDKConfig (Internal)
- (BOOL)isLegal {
    return (self.appId.length > 0);
}
@end

@implementation AgoraEduLaunchConfig (Internal)
- (BOOL)isLegal {
    if (self.userName.length <= 0) {
        return NO;
    }
    
    if (self.userUuid.length <= 0) {
        return NO;
    }
    
    if (self.roomName.length <= 0) {
        return NO;
    }
    
    if (self.roomUuid.length <= 0) {
        return NO;
    }
    
    if (!(self.roomType == AgoraEduRoomTypeOneToOne
          || self.roomType == AgoraEduRoomTypeSmall
          || self.roomType == AgoraEduRoomTypeLecture)) {
        return NO;
    }
    
    if (self.token.length <= 0) {
        return NO;
    }
    
    if (self.startTime == nil) {
        return NO;
    }
    
    if (self.region.length <= 0) {
        return NO;
    }
    
    return YES;
}
@end
