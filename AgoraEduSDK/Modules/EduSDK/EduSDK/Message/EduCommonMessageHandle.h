//
//  EduCommonMessageHandle.h
//  EduSDK
//
//  Created by SRS on 2020/8/31.
//

#import <Foundation/Foundation.h>
#import "EduMessageHandle.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduCommonMessageHandle : EduMessageHandle

@property (nonatomic, weak) id<EduManagerDelegate> agoraDelegate;

- (MessageHandleCode)didReceivedPeerMsg:(NSString *)text;
- (void)didReceivedConnectionStateChanged:(ConnectionState)state complete:(void (^) (ConnectionState state))block;

@end

NS_ASSUME_NONNULL_END
