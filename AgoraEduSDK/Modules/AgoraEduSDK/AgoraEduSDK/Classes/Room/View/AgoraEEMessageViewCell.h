//
//  AgoraEEMessageViewCell.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/11.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgoraEETextMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraEEMessageViewCell : UITableViewCell

- (CGSize)sizeWithContent:(NSString *)string;

@property (nonatomic, copy) AgoraEETextMessage *messageModel;
@property (nonatomic, assign) CGFloat cellWidth;

@end

NS_ASSUME_NONNULL_END
