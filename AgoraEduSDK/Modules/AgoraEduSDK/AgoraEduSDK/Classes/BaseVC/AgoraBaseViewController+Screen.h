//
//  AgoraBaseViewController+Screen.h
//  AgoraEduSDK
//
//  Created by LYY on 2021/3/18.
//

#import "AgoraBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraBaseViewController (Screen)<AgoraEduScreenShareContext>
- (void)onUpdateScreenShareState:(BOOL)sharing streamUuid:(NSString *)streamUuid;
@end

NS_ASSUME_NONNULL_END
