//
//  AgoraEEMessageView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/11.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgoraEEMessageViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraEEMessageView : UIView

- (void)addMessageModel:(AgoraEETextMessage *)model;
- (void)updateTableView;
@end

NS_ASSUME_NONNULL_END
