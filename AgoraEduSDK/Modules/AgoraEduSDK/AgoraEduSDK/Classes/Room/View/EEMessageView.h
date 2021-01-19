//
//  EEMessageView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/11.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EEMessageViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface EEMessageView : UIView

- (void)addMessageModel:(EETextMessage *)model;
- (void)updateTableView;
@end

NS_ASSUME_NONNULL_END
