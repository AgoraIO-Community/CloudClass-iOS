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

@interface AgoraWhiteBoardStateModel()
@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, assign) BOOL teacherFirstLogin;
@property (nonatomic, strong) NSArray<NSString *> *grantUsers;
@property (nonatomic, strong) NSArray<AgoraWhiteBoardTaskModel *> * materialList;
@end

@implementation AgoraWhiteBoardStateModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"materialList" : [AgoraWhiteBoardTaskModel class]};
}
@end

@implementation AgoraWhiteGlobalStateTaskModel

@end

@implementation AgoraWhiteGlobalStateModel
- (instancetype)init {
    self = [super init];
    if (self) {
        self.isFullScreen = NO;
        self.teacherFirstLogin = NO;
    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"materialList" : [AgoraWhiteGlobalStateTaskModel class]};
}
@end
