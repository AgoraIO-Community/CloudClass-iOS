//
//  WhiteBoardManager.h
//  AgoraWhiteBoard
//
//  Created by SRS on 2020/7/14.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WhiteBoardConfiguration.h"
#import "WhiteBoardJoinOptions.h"
#import "WhiteBoardStateModel.h"

@protocol WhiteManagerDelegate <NSObject>

- (void)onWhiteBoardStateChanged:(WhiteBoardStateModel * _Nonnull)state;

@optional
- (void)onWhiteBoardError:(NSError *)error;
@end

NS_ASSUME_NONNULL_BEGIN

@interface WhiteBoardManager : NSObject

@property (nonatomic, weak) id<WhiteManagerDelegate> delegate;

// generate board view
- (UIView *)getBoardView;

// generate board view
- (WhiteBoardStateModel *)getWhiteBoardStateModel;

// init
- (void)initBoardWithView:(UIView *)boardView config:(WhiteBoardConfiguration *)config;

// join
- (void)joinBoardWithOptions:(WhiteBoardJoinOptions *)options success:(void (^) (void))successBlock failure:(void (^) (NSError * error))failureBlock;

// allow teaching aids
- (void)allowTeachingaids:(BOOL)allow success:(void (^) (void))successBlock failure:(void (^) (NSError * error))failureBlock;

// when board view size changed, must call refreshViewSize
- (void)refreshViewSize;

// move courseware
- (void)moveViewToContainer:(CGSize)size;

// lock view
- (void)lockViewTransform:(BOOL)lock;

// leave
- (void)leaveBoardWithSuccess:(void (^ _Nullable) (void))successBlock failure:(void (^ _Nullable) (void))failureBlock;

@end

NS_ASSUME_NONNULL_END
