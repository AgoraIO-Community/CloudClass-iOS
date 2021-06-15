//
//  AgoraHttpModel.m
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/8.
//

#import "AgoraHttpModel.h"

@implementation AgoraBaseModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.code = -1;
        self.msg = nil;
        self.message = nil;
    }
    return self;
}
@end

@implementation AgoraRoomStateAgoraBoardModel
@end
@implementation AgoraRoomStateInfoModel
@end
@implementation AgoraRoomStateModel
@end

@implementation AgoraChatModel
@end

@implementation AgoraBoardConfigInfoModel
@end
@implementation AgoraConfigInfoModel
@end
@implementation AgoraConfigModel
@end

@implementation AgoraHandUpModel
@end

