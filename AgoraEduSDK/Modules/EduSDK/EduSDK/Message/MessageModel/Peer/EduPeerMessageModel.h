//
//  EduPeerMessageModel.h
//  EduSDK
//
//  Created by SRS on 2020/7/26.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PeerMessageCmd) {
    PeerMessageCmdChat                   = 1,
    PeerMessageCmdApplyOrInvitation      = 2,
    PeerMessageCmdExtention              = 99,
};


NS_ASSUME_NONNULL_BEGIN

@interface EduPeerMessageModel : NSObject
@property (nonatomic, assign) PeerMessageCmd cmd;
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, assign) NSInteger ts;
@property (nonatomic, strong) NSString *requestId;
@property (nonatomic, strong) NSDictionary *data;
@end

NS_ASSUME_NONNULL_END
