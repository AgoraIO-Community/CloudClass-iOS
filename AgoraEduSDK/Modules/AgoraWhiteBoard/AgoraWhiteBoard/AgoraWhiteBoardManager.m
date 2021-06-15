//
//  AgoraWhiteBoardManager.m
//  AgoraWhiteBoard
//
//  Created by SRS on 2020/7/14.
//  Copyright © 2020 agora. All rights reserved.
//

#import "AgoraWhiteBoardManager.h"
#import <Whiteboard/Whiteboard.h>
#import "AgoraWhiteURLSchemeHandler.h"

// Error
#define AgoraBoardLocalErrorCode 9991

#define AgoraBoardLocalErrorDomain @"io.agora.AgoraWhiteBoard"
#define AgoraBoardLocalError(errCode, reason) ([NSError errorWithDomain:AgoraBoardLocalErrorDomain \
    code:(errCode) \
userInfo:@{NSLocalizedDescriptionKey:(reason)}])

@interface AgoraWhiteBoardManager() <WhiteCommonCallbackDelegate, WhiteRoomCallbackDelegate>
@property (nonatomic, strong) AgoraWhiteURLSchemeHandler *schemeHandler API_AVAILABLE(ios(11.0));
@property (nonatomic, strong) WhiteSDK *whiteSDK;
@property (nonatomic, strong) WhiteRoom *room;
@property (nonatomic, strong) WhiteMemberState *whiteMemberState;
@property (nonatomic, assign) BOOL isWritable;
@property (nonatomic, copy) NSString *boardScenePath;
@end

@implementation AgoraWhiteBoardManager
#pragma mark - Public
- (instancetype)initWithCoursewareDirectory:(NSString *)directory
                                boardRegion:(NSString *)boardRegion
                                     config:(AgoraWhiteBoardConfiguration *)config {
    self = [super init];
    if (self) {
        self.isWritable = YES;
        self.scenePath = @"";
        
        if (@available(iOS 11.0, *)) {
            // 在初始化 sdk 时，配置 PPTParams 的 scheme，保证与此处传入的 scheme 一致。
            self.schemeHandler = [[AgoraWhiteURLSchemeHandler alloc] initWithScheme:AgoraWhiteCoursewareScheme
                                                                          directory:directory];
        }
        
        [self initContentViewWithAppId:config.appId
                           boardRegion:boardRegion
                                 fonts:config.fonts];
    }
    return self;
}

- (AgoraWhiteBoardStateModel *)getWhiteBoardStateModel {
    id modelObj = [self.room.state.globalState yy_modelToJSONObject];
    AgoraWhiteBoardStateModel *state = [AgoraWhiteBoardStateModel new];
    [state yy_modelSetWithJSON:modelObj];
    return state;
}

- (UIView *)contentView {
    if (_contentView) {
        return _contentView;
    }
    
    if (@available(iOS 11, *)) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        [config setURLSchemeHandler:self.schemeHandler
                       forURLScheme:AgoraWhiteCoursewareScheme];
        WhiteBoardView *boardView = [[WhiteBoardView alloc] initWithFrame:CGRectZero
                                                            configuration:config];
        
        _contentView = boardView;
    } else {
        WhiteBoardView *boardView = [[WhiteBoardView alloc] init];
        _contentView = boardView;
    }
    
    return _contentView;
}

- (void)joinWithOptions:(AgoraWhiteBoardJoinOptions *)options
                success:(void (^) (void))successBlock
                failure:(void (^) (NSError * error))failureBlock {
    
    __weak AgoraWhiteBoardManager *weakself = self;
    
    WhiteRoomConfig *roomConfig = [[WhiteRoomConfig alloc] initWithUuid:options.boardId
                                                              roomToken:options.boardToken];
    roomConfig.isWritable = self.isWritable;
    roomConfig.disableNewPencil = NO;
    
    [self.whiteSDK joinRoomWithConfig:roomConfig
                            callbacks:self
                    completionHandler:^(BOOL success, WhiteRoom * _Nullable room, NSError * _Nullable error) {
        
        if (success) {
            weakself.room = room;
            weakself.whiteMemberState = [WhiteMemberState new];
            [weakself.room setMemberState:weakself.whiteMemberState];
            
            WhiteSceneState *sceneState = room.sceneState;
            NSArray<WhiteScene *> *scenes = sceneState.scenes;
            NSInteger sceneIndex = sceneState.index;
            WhiteScene *scene = scenes[sceneIndex];
            
            if (scene.ppt) {
                [self.room scalePptToFit:WhiteAnimationModeContinuous];
            }
            
            [weakself refreshViewSize];
            
            if (successBlock) {
                successBlock();
            }
            
            if ([weakself.delegate respondsToSelector:@selector(onWhiteBoardPageChanged:pageCount:)]) {
                [weakself.delegate onWhiteBoardPageChanged:sceneIndex
                                                 pageCount:scenes.count];
            }
        } else {
            if (failureBlock) {
                failureBlock(error);
            }
        }
    }];
}

// allow teaching aids
// 允许使用教具
- (void)allowTeachingaids:(BOOL)allow
                  success:(void (^) (void))successBlock
                  failure:(void (^) (NSError * error))failureBlock {
    [self.room disableDeviceInputs:!allow];
    
    if (allow == self.isWritable) {
        if(successBlock) {
            successBlock();
        }
        return;
    }

    __weak AgoraWhiteBoardManager *weakself = self;
    
    [self.room setWritable:allow completionHandler:^(BOOL isWritable, NSError * _Nullable error) {
        weakself.isWritable = isWritable;
        if (error && failureBlock) {
            failureBlock(error);
        } else if (successBlock) {
            successBlock();
        }
    }];
}

- (void)setFollowMode:(BOOL)follow{
    if (follow) {
        [self.room setViewMode:WhiteViewModeFollower];
    } else {
        [self.room setViewMode:WhiteViewModeFreedom];
    }
    
}

// when board view size changed, must call refreshViewSize
// 当 WhiteBoardView 的 super view 的 frame 变化时，需要调用这个方法
- (void)refreshViewSize {
     [self.room refreshViewSize];
}

// 重置缩放比例
- (void)resetViewSize {
    WhiteSceneState *sceneState = self.room.sceneState;
    NSArray<WhiteScene *> *scenes = sceneState.scenes;
    NSInteger sceneIndex = sceneState.index;
    WhiteScene *scene = scenes[sceneIndex];
    if (scene.ppt) {
        [self.room scalePptToFit:WhiteAnimationModeContinuous];
    } else {
        WhiteCameraConfig *config = [WhiteCameraConfig new];
        config.scale = @(1);
        config.centerY = @(0);
        config.centerX = @(0);
        [self.room moveCamera:config];
    }
}

- (void)putScenes:(NSString *)dir
           scenes:(NSArray<WhiteScene *> *)scenes
            index:(NSUInteger)index {
    [self.room putScenes:dir
                  scenes:scenes
                   index:index];
}

- (void)setScenePath:(NSString *)path {
    [self.room setScenePath:path];
}

// lock view
- (void)lockViewTransform:(BOOL)lock {
    [self.room disableCameraTransform:lock];
}

// leave
- (void)leaveWithSuccess:(void (^ _Nullable) (void))successBlock
                 failure:(void (^ _Nullable) (void))failureBlock {
    self.isWritable = NO;
    
    if (self.room) {
        [self.room disconnect:nil];
    }

    self.room = nil;
    self.whiteSDK = nil;
    
    self.boardScenePath = @"";
}

#pragma mark - Update tools properties
- (void)setTool:(AgoraWhiteBoardToolType)type; {
    [self setApplianceNameWithToolType:type];
    [self setWhiteMemberState];
}

- (void)setColor:(UIColor *)color {
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    [color getRed:&red
            green:&green
             blue:&blue
            alpha:&alpha];
    
    NSInteger redValue = red * 255;
    NSInteger greenValue = green * 255;
    NSInteger blueValue = blue * 255;
    
    self.whiteMemberState.strokeColor = @[@(redValue),
                                          @(greenValue),
                                          @(blueValue)];
    [self setWhiteMemberState];
}

- (void)setStrokeWidth:(NSInteger)strokeWidth {
    self.whiteMemberState.strokeWidth = @(strokeWidth);
    [self setWhiteMemberState];
}

- (void)setTextSize:(NSInteger)textSize {
    self.whiteMemberState.textSize = @(textSize);
    [self setWhiteMemberState];
}

- (void)setStrokeColor:(UIColor *)color
          withToolType:(AgoraWhiteBoardToolType)type {
    [self setApplianceNameWithToolType:type];
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    [color getRed:&red
            green:&green
             blue:&blue
            alpha:&alpha];
    
    NSInteger redValue = red * 255;
    NSInteger greenValue = green * 255;
    NSInteger blueValue = blue * 255;
    
    self.whiteMemberState.strokeColor = @[@(redValue),
                                          @(greenValue),
                                          @(blueValue)];
    [self setWhiteMemberState];
}

- (void)setStrokeWidth:(NSInteger)strokeWidth
          withToolType:(AgoraWhiteBoardToolType)type {
    [self setApplianceNameWithToolType:type];
    self.whiteMemberState.strokeWidth = @(strokeWidth);
    [self setWhiteMemberState];
}

- (void)setTextSize:(NSInteger)textSize
       withToolType:(AgoraWhiteBoardToolType)type {
    [self setApplianceNameWithToolType:type];
    self.whiteMemberState.textSize = @(textSize);
    [self setWhiteMemberState];
}

- (void)setWhiteMemberState {
    NSLog(@"currentApplianceName: %@", self.whiteMemberState.currentApplianceName);
    [self.room setMemberState:self.whiteMemberState];
}

- (void)onSetPageIndex:(NSUInteger)index {
    __weak AgoraWhiteBoardManager *weakself = self;
    [self.room setSceneIndex:index completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        if (!success && error != nil) {
            if ([weakself.delegate respondsToSelector:@selector(onWhiteBoardError:)]) {
                [weakself.delegate onWhiteBoardError: error];
            }
        }
    }];
}

- (void)increaseScale {
    __weak AgoraWhiteBoardManager *weakself = self;
    [self.room getZoomScaleWithResult:^(CGFloat scale) {
        WhiteCameraConfig *config = [WhiteCameraConfig new];
        config.scale = @(scale + 0.1);
        [weakself.room moveCamera:config];
    }];
}

- (void)decreaseScale {
    __weak AgoraWhiteBoardManager *weakself = self;
    [self.room getZoomScaleWithResult:^(CGFloat scale) {
        WhiteCameraConfig *config = [WhiteCameraConfig new];
        CGFloat ss = scale - 0.1;
        config.scale = @(ss < 0.1 ? 0.1 : ss);
        [weakself.room moveCamera:config];
    }];
}

#pragma mark - Private
- (void)initContentViewWithAppId:(NSString *)appId
                     boardRegion:(NSString *)boardRegion
                           fonts:(NSDictionary *)fonts {
    WhiteSdkConfiguration *config = [[WhiteSdkConfiguration alloc] initWithApp:appId];
    
    if (@available(iOS 11.0, *)) {
        WhitePptParams *pptParams = [[WhitePptParams alloc] init];
        pptParams.scheme = AgoraWhiteCoursewareScheme;
        config.pptParams = pptParams;
    }
    
    config.fonts = fonts;
    config.userCursor = YES;
    config.region = [self getBoardRegionKey:boardRegion];
    
    self.whiteSDK = [[WhiteSDK alloc] initWithWhiteBoardView:self.contentView
                                                      config:config
                                      commonCallbackDelegate:self];
    
    [WhiteDisplayerState setCustomGlobalStateClass:AgoraWhiteGlobalStateModel.class];
}

- (WhiteRegionKey)getBoardRegionKey:(NSString *)boardRegion {
    if ([boardRegion isEqualToString:WhiteRegionUS]) {
        return WhiteRegionUS;
    }else if ([boardRegion isEqualToString:WhiteRegionGB]) {
        return WhiteRegionGB;
    }else if ([boardRegion isEqualToString:WhiteRegionSG]) {
        return WhiteRegionSG;
    } else if ([boardRegion isEqualToString:WhiteRegionCN]){
        return WhiteRegionCN;
    } else {
        return WhiteRegionUS; // default
    }
}

- (void)setApplianceNameWithToolType:(AgoraWhiteBoardToolType)type {
    NSString *applianceName = @"";
    
    switch (type) {
        case WhiteBoardToolTypeSelector:
            applianceName = ApplianceSelector;
            break;
        case WhiteBoardToolTypePencil:
            applianceName = AppliancePencil;
            break;
        case WhiteBoardToolTypeText:
            applianceName = ApplianceText;
            break;
        case WhiteBoardToolTypeEraser:
            applianceName = ApplianceEraser;
            break;
        case WhiteBoardToolTypeRectangle:
            applianceName = ApplianceRectangle;
            break;
        case WhiteBoardToolTypeEllipse:
            applianceName = ApplianceEllipse;
            break;
        case WhiteBoardToolTypeArrow:
            applianceName = ApplianceArrow;
            break;
        case WhiteBoardToolTypeStraight:
            applianceName = ApplianceStraight;
            break;
        case WhiteBoardToolTypePointer:
            applianceName = ApplianceLaserPointer;
            break;
        case WhiteBoardToolTypeColor:
            return;
    }
    
    self.whiteMemberState.currentApplianceName = applianceName;
}

#pragma mark - WhiteRoomCallbackDelegate
/**
The RoomState property in the room will trigger this callback when it changes.
*/
- (void)fireRoomStateChanged:(WhiteRoomState *_Nullable)modifyState {
    // TODO: 啥意思
    if (modifyState.broadcastState && modifyState.broadcastState.broadcasterId == nil) {
        [self.room scalePptToFit:WhiteAnimationModeContinuous];
    }
    
    // 全局状态 WhiteGlobalState 修改时
    if (modifyState.globalState) {
        id modelObj = [modifyState.globalState yy_modelToJSONObject];
        AgoraWhiteBoardStateModel *state = [AgoraWhiteBoardStateModel new];
        [state yy_modelSetWithJSON:modelObj];
        
        if ([self.delegate respondsToSelector:@selector(onWhiteBoardStateChanged:)]) {
            [self.delegate onWhiteBoardStateChanged:state];
        }
    }
    
    // 场景状态 WhiteSceneState 修改时
    if (modifyState.sceneState) {
        WhiteSceneState *sceneState = self.room.sceneState;
        NSArray<WhiteScene *> *scenes = sceneState.scenes;
        NSInteger sceneIndex = sceneState.index;
        WhiteScene *scene = scenes[sceneIndex];
        
        if (scene.ppt) {
            [self.room scalePptToFit:WhiteAnimationModeContinuous];
        }
        
        if ([self.delegate respondsToSelector:@selector(onWhiteBoardPageChanged:pageCount:)]) {
            [self.delegate onWhiteBoardPageChanged:sceneIndex
                                         pageCount:scenes.count];
        }
        
        if (![sceneState.scenePath isEqualToString:self.boardScenePath]) {
            self.boardScenePath = sceneState.scenePath;
            if ([self.delegate respondsToSelector:@selector(onWhiteBoardSceneChanged:)]) {
                [self.delegate onWhiteBoardSceneChanged:self.boardScenePath];
            }
        }
    }
}
/** 白板失去连接回调，附带错误信息 */
- (void)fireDisconnectWithError:(NSString *)error {
    if ([self.delegate respondsToSelector:@selector(onWhiteBoardError:)]) {
        NSError *err = AgoraBoardLocalError(AgoraBoardLocalErrorCode, error);
        [self.delegate onWhiteBoardError: err];
    }
}

/** 用户被远程服务器踢出房间，附带踢出原因 */
- (void)fireKickedWithReason:(NSString *)reason {
    if ([self.delegate respondsToSelector:@selector(onWhiteBoardError:)]) {
        NSError *err = AgoraBoardLocalError(AgoraBoardLocalErrorCode, reason);
        [self.delegate onWhiteBoardError: err];
    }
}

/** 用户错误事件捕获，附带用户 id，以及错误原因 */
- (void)fireCatchErrorWhenAppendFrame:(NSUInteger)userId error:(NSString *)error {
    if ([self.delegate respondsToSelector:@selector(onWhiteBoardError:)]) {
        NSError *err = AgoraBoardLocalError(AgoraBoardLocalErrorCode, error);
        [self.delegate onWhiteBoardError: err];
    }
}

#pragma mark - WhiteCommonCallbackDelegate
/** 当sdk出现未捕获的全局错误时，会在此处对抛出 NSError 对象 */
- (void)throwError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(onWhiteBoardError:)]) {
        [self.delegate onWhiteBoardError: error];
    }
}

#pragma mark - AgoraWhiteBoardColorControlDelegate
- (void)onSelectColor:(UIColor *)color {
    NSInteger numComponents = CGColorGetNumberOfComponents(color.CGColor);
    NSArray *array = nil;
    if (numComponents == 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        array = @[@((int)(components[0] * 255)),
                  @((int)(components[1] * 255)),
                  @((int)(components[2] * 255))];
    }
    self.whiteMemberState.strokeColor = array;
    [self setWhiteMemberState];
}
@end
