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
          || self.roomType == AgoraEduRoomTypeLecture
          || self.roomType == AgoraEduRoomTypePaintingSmall)) {
        return NO;
    }
    
    if (self.token.length <= 0) {
        return NO;
    }
    
    if (self.startTime == nil) {
        return NO;
    }
    
    return YES;
}
@end

@implementation AgoraClassroomSDK (Internal)
+ (NSArray<AgoraEduCorePuppetCourseware *> * _Nullable)getPuppetBoardModelCoursewares:(NSArray<AgoraEduCourseware *> *)coursewares {
    if (coursewares.count <= 0) {
        return nil;
    }
    
    NSMutableArray<AgoraEduCorePuppetCourseware *> *puppetCoursewares = [NSMutableArray array];
    
    for (AgoraEduCourseware *courseware in coursewares) {
        NSMutableArray *puppetScenes = [NSMutableArray array];
        
        // board scene
        for (AgoraEduBoardScene *scene in courseware.scenes) {
            // board ppt
            AgoraEduPPTPage *ppt = scene.pptPage;
            AgoraEduCorePuppetPPTPage *puppetPPT = nil;
            
            if (ppt) {
                puppetPPT = [[AgoraEduCorePuppetPPTPage alloc] initWithSource:ppt.source
                                                                   previewURL:ppt.previewURL
                                                                         size:CGSizeMake(ppt.width,
                                                                                         ppt.height)];
            }
            
            AgoraEduCorePuppetBoardScene *puppetScene = [[AgoraEduCorePuppetBoardScene alloc] initWithName:scene.name
                                                                                                   pptPage:puppetPPT];
            
            [puppetScenes addObject:puppetScene];
        }
        
        AgoraEduCorePuppetCourseware *puppetCourseware = [[AgoraEduCorePuppetCourseware alloc] initWithResourceName:courseware.resourceName
                                                                                                       resourceUuid:courseware.resourceUuid
                                                                                                          scenePath:courseware.scenePath
                                                                                                        resourceURL:courseware.resourceUrl
                                                                                                             scenes:puppetScenes
                                                                                                                ext:courseware.ext
                                                                                                               size:courseware.size
                                                                                                         updateTime:courseware.updateTime];
        [puppetCoursewares addObject:puppetCourseware];
    }
    
    return puppetCoursewares;
}

+ (AgoraEduCorePuppetMediaOptions *)getPuppetMediaOptions:(AgoraEduMediaOptions *)options {
    AgoraEduCorePuppetVideoConfig *videoConfig = nil;
    if (options.cameraEncoderConfiguration) {
        videoConfig = [[AgoraEduCorePuppetVideoConfig alloc] initWithVideoDimensionWidth:options.cameraEncoderConfiguration.width
                                                                    videoDimensionHeight:options.cameraEncoderConfiguration.height
                                                                               frameRate:options.cameraEncoderConfiguration.frameRate
                                                                                 bitRate:options.cameraEncoderConfiguration.bitrate
                                                                              mirrorMode:options.cameraEncoderConfiguration.mirrorMode];
    }
    AgoraEduCorePuppetMediaEncryptionConfig *encryptionConfig = nil;
    if (options.encryptionConfig) {
        NSString *key = options.encryptionConfig.key;
        AgoraEduCorePuppetMediaEncryptionMode mode = options.encryptionConfig.mode;
        encryptionConfig = [[AgoraEduCorePuppetMediaEncryptionConfig alloc] initWithKey:key
                                                                                   mode:mode];
    }
    AgoraEduCorePuppetMediaOptions *mediaOptions = [[AgoraEduCorePuppetMediaOptions alloc] initWithEncryptionConfig:encryptionConfig
                                                                                                        videoConfig:videoConfig
                                                                                                       latencyLevel:options.latencyLevel
                                                                                                         videoState:options.videoState
                                                                                                         audioState:options.audioState];
    return mediaOptions;
}
@end

