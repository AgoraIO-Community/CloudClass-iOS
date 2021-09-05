//
//  EMMessageTimeCell.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/20.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMMessageStringCell : UITableViewCell

@property (nonatomic, strong) UILabel *stringLabel;

@property (nonatomic, strong) UIImageView *preImageView;

- (void)updatetext:(NSString*)aText;

@end

NS_ASSUME_NONNULL_END
