//
//  AgoraWhiteBoardManager.h
//  AgoraWhiteBoard
//
//  Created by SRS on 2020/7/14.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Whiteboard/Whiteboard.h>
#import <UIKit/UIKit.h>
#import "AgoraWhiteBoardModels.h"
#import "AgoraWhiteBoardEnums.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AgoraWhiteManagerDelegate <NSObject>
- (void)onWhiteBoardStateChanged:(AgoraWhiteBoardStateModel *)state;
- (void)onWhiteBoardCameraConfigChange:(AgoraWhiteBoardCameraConfig *)config;
- (void)onWhiteBoardDisConnectedUnexpected;

@optional
- (void)onWhiteBoardError:(NSError *)error;
- (void)onWhiteBoardPageChanged:(NSInteger)pageIndex
                      pageCount:(NSInteger)pageCount;

- (void)onWhiteBoardSceneChanged:(NSString *)scenePath;
@end

@interface AgoraWhiteBoardManager: NSObject
@property (nonatomic, weak) id<AgoraWhiteManagerDelegate> delegate;
@property (nonatomic, strong) WKWebView *contentView;

- (instancetype)initWithCoursewareDirectory:(NSString *)directory
                                     config:(AgoraWhiteBoardConfiguration *)config;

- (AgoraWhiteBoardStateModel *)getWhiteBoardStateModel;
- (void)setWhiteBoardStateModel:(AgoraWhiteBoardStateModel *)state;

- (void)setCourseIconStyle:(NSDictionary *)style;

// join
- (void)joinWithOptions:(AgoraWhiteBoardJoinOptions *)options
                success:(void (^) (void))successBlock
                failure:(void (^) (NSError * error))failureBlock;

// allow teaching aids
- (void)allowTeachingaids:(BOOL)allow
                  success:(void (^) (void))successBlock
                  failure:(void (^) (NSError * error))failureBlock;

- (void)setFollowMode:(BOOL)follow;

- (AgoraWhiteBoardCameraConfig *)getBoardCameraConfig;
- (void)setBoardCameraConfig:(AgoraWhiteBoardCameraConfig *)config;

// when board view size changed, must call refreshViewSize
- (void)refreshViewSize;
- (void)resetViewSize;

- (void)putScenes:(NSString *)dir
           scenes:(NSArray<WhiteScene *> *)scenes
            index:(NSUInteger)index;

- (void)setScenePath:(NSString *)path;

// update tools properties
- (void)setTool:(AgoraWhiteBoardToolType)type;

- (void)setColor:(UIColor *)color;

- (void)setStrokeWidth:(NSInteger)strokeWidth;

- (void)setTextSize:(NSInteger)textSize;

- (void)setStrokeColor:(UIColor *)color
          withToolType:(AgoraWhiteBoardToolType)type;

- (void)setStrokeWidth:(NSInteger)strokeWidth
          withToolType:(AgoraWhiteBoardToolType)type;

- (void)setTextSize:(NSInteger)textSize
       withToolType:(AgoraWhiteBoardToolType)type;

// pageindex
- (void)setPageIndex:(NSUInteger)index;

// scale
- (void)increaseScale;
- (void)decreaseScale;

// lock view
- (void)lockViewTransform:(BOOL)lock;

// leave
- (void)leave;
@end

NS_ASSUME_NONNULL_END
