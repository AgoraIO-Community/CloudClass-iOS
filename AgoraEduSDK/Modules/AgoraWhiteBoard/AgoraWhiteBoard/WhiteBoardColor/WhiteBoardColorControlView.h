//
//  WhiteBoardColorControlView.h
//  AgoraWhiteBoard
//
//  Created by SRS on 2020/7/14.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WhiteBoardColorControlDelegate <NSObject>
- (void)onSelectColor:(UIColor *)color;
@end


@interface WhiteBoardColorControlView : UIView

@property (nonatomic, weak) id <WhiteBoardColorControlDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
