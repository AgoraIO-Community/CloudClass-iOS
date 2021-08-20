//
//  AgoraWhiteBoardModels.m
//  AgoraWhiteBoard
//
//  Created by Cavan on 2021/3/19.
//  Copyright © 2021 agora. All rights reserved.
//

#import "AgoraWhiteBoardModels.h"

@implementation AgoraWhiteBoardConfiguration

@end

@implementation AgoraWhiteBoardJoinOptions

@end

@interface AgoraWhiteBoardTaskModel()
@property (nonatomic, strong) NSString *resourceUuid;
@property (nonatomic, strong) NSString *taskUuid;
@property (nonatomic, strong) NSString *ext;
@end
@implementation AgoraWhiteBoardTaskModel
@end

@implementation AgoraWhiteBoardExtAppMovement
@end


@implementation AgoraWhiteBoardStateModel
- (instancetype)init {
    self = [super init];
    if (self) {
        self.isFullScreen = NO;
        self.teacherFirstLogin = NO;
    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"materialList" : [AgoraWhiteBoardTaskModel class]};
}
@end

@implementation AgoraWhiteBoardCameraConfig
- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.centerX = 0;
        self.centerY = 0;
        self.scale = 1;
    }
    
    return self;
}

@end
