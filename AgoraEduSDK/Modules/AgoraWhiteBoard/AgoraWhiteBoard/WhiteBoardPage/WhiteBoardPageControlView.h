//
//  WhiteBoardPageControlView.h
//  AgoraWhiteBoard
//
//  Created by SRS on 2020/7/14.
//  Copyright © 2020 agora. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WihteBoardPageControlDelegate <NSObject>
- (void)selectPageIndex:(NSInteger)pageIndex completeBlock:(void (^ _Nullable)(BOOL isSuccess, NSError *error))block;
@end

@interface WhiteBoardPageControlView : UIView

@property (nonatomic, weak) id <WihteBoardPageControlDelegate> delegate;

- (void)setPageIndex:(NSInteger)pageIndex pageCount:(NSInteger)pageCount;

@end

NS_ASSUME_NONNULL_END
