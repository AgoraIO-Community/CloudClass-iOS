//
//  AgoraBaseViewController+User.h
//  AgoraEduSDK
//
//  Created by SRS on 2021/3/15.
//

#import "AgoraBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraBaseViewController (User)<AgoraEduUserContext>
- (void)onUpdateUserList:(NSArray<AgoraEduContextUserDetailInfo*> *)list;
- (void)onUpdateCoHostList:(NSArray<AgoraEduContextUserDetailInfo*> *)list;
- (void)onKickedOut;
- (void)onUpdateAudioVolumeIndication:(NSInteger)value streamUuid:(NSString *)streamUuid;
- (void)onShowUserTips:(NSString *)message;
@end

NS_ASSUME_NONNULL_END
