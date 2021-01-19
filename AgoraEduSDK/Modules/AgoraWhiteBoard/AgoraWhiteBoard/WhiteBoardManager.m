//
//  WhiteBoardManager.m
//  AgoraWhiteBoard
//
//  Created by SRS on 2020/7/14.
//  Copyright © 2020 agora. All rights reserved.
//

#import "WhiteBoardManager.h"
#import <Whiteboard/Whiteboard.h>
#import "WhiteBoardUtil.h"
#import "AgoraWhiteBoardViewManager.h"
#import "WhiteGlobalStateModel.h"

// Error
#define LocalAgoraBoardErrorCode 9991

#define LocalErrorDomain @"io.agora.AgoraWhiteBoard"
#define LocalError(errCode, reason) ([NSError errorWithDomain:LocalErrorDomain \
    code:(errCode) \
userInfo:@{NSLocalizedDescriptionKey:(reason)}])

@interface WhiteBoardManager()<WhiteCommonCallbackDelegate, WhiteRoomCallbackDelegate, WhiteBoardColorControlDelegate, WihteBoardToolControlDelegate, WihteBoardPageControlDelegate>

@property (nonatomic, strong) WhiteSDK *whiteSDK;
@property (nonatomic, strong) WhiteRoom *room;
@property (nonatomic, strong) WhiteMemberState *whiteMemberState;

@property (nonatomic, strong) AgoraWhiteBoardViewManager *boardViewManager;
@property (nonatomic, assign) BOOL isWritable;

@end

@implementation WhiteBoardManager
- (instancetype)init {
    self = [super init];
    if (self) {
        self.isWritable = NO;
    }
    return self;
}

// generate board view
- (UIView *)getBoardView {
    WhiteBoardView *boardView = [[WhiteBoardView alloc] init];
    return boardView;
}

- (WhiteBoardStateModel *)getWhiteBoardStateModel {
    
    WhiteGlobalStateModel *model = (WhiteGlobalStateModel*)self.room.state.globalState;
    id modelObj = [self.room.state.globalState yy_modelToJSONObject];
    WhiteBoardStateModel *state = [WhiteBoardStateModel new];
    [state yy_modelSetWithJSON:modelObj];
    return state;
}

// init
- (void)initBoardWithView:(UIView *)boardView config:(WhiteBoardConfiguration *)config {
    
    WhiteBoardView *whiteBoardView = (WhiteBoardView*)boardView;
    if (whiteBoardView) {
        
        self.boardViewManager = [AgoraWhiteBoardViewManager new];
        self.boardViewManager.boardView = whiteBoardView;
        self.boardViewManager.pageControlView.delegate = self;
        self.boardViewManager.toolControlView.delegate = self;
        self.boardViewManager.colorControlView.delegate = self;
        
        WhiteSdkConfiguration *_config = [[WhiteSdkConfiguration alloc] initWithApp:config.appId];
        if(config) {
            _config.fonts = config.fonts;
        }
        
        self.whiteSDK = [[WhiteSDK alloc] initWithWhiteBoardView: whiteBoardView config:_config commonCallbackDelegate:self];
        [WhiteDisplayerState setCustomGlobalStateClass:WhiteGlobalStateModel.class];
    } else {
        NSAssert(1 == 0, @"boardView must be belong WhiteBoardView");
    }
}

// join
- (void)joinBoardWithOptions:(WhiteBoardJoinOptions *)options success:(void (^) (void))successBlock failure:(void (^) (NSError * error))failureBlock {
    
    WhiteRoomConfig *roomConfig = [[WhiteRoomConfig alloc] initWithUuid:options.boardId roomToken:options.boardToken];
    roomConfig.isWritable = self.isWritable;

    WEAK(self);
    [self.whiteSDK joinRoomWithConfig:roomConfig callbacks:self completionHandler:^(BOOL success, WhiteRoom * _Nullable room, NSError * _Nullable error) {

        if (success) {
            weakself.room = room;
            weakself.whiteMemberState = [WhiteMemberState new];
            [weakself.room setMemberState:weakself.whiteMemberState];
            
            WhiteSceneState *sceneState = room.sceneState;
            NSArray<WhiteScene *> *scenes = sceneState.scenes;
            NSInteger sceneIndex = sceneState.index;
            WhiteScene *scene = scenes[sceneIndex];
            if (scene.ppt) {
                CGSize size = CGSizeMake(scene.ppt.width, scene.ppt.height);
                [weakself moveViewToContainer:size];
            }
            [weakself.boardViewManager.pageControlView setPageIndex:sceneIndex pageCount:scenes.count];
            [weakself.boardViewManager.boardView layoutIfNeeded];
            [weakself refreshViewSize];
            if(successBlock != nil){
                successBlock();
            }
        } else {
            if(failureBlock != nil){
                failureBlock(error);
            }
        }
    }];
}

// allow teaching aids
- (void)allowTeachingaids:(BOOL)allow success:(void (^) (void))successBlock failure:(void (^) (NSError * error))failureBlock {
    
    [self.room disableDeviceInputs:!allow];
    
    self.boardViewManager.toolControlView.hidden = !allow;
    if(!allow) {
        self.boardViewManager.colorControlView.hidden = !allow;
    }
    self.boardViewManager.pageControlView.hidden = !allow;
    if(allow == self.isWritable) {
        if(successBlock) {
            successBlock();
        }
        return;
    }

    WEAK(self);
    [self.room setWritable:allow completionHandler:^(BOOL isWritable, NSError * _Nullable error) {
        weakself.isWritable = isWritable;
        if (error && failureBlock) {
            failureBlock(error);
        } else if (successBlock) {
            successBlock();
        }
    }];
}

// when board view size changed, must call refreshViewSize
- (void)refreshViewSize {
     [self.room refreshViewSize];
}

// move courseware
- (void)moveViewToContainer:(CGSize)size {

    WhiteRectangleConfig *config = [[WhiteRectangleConfig alloc] initWithInitialPosition:size.width height:size.height];
    [self.room moveCameraToContainer:config];
}

// lock view
- (void)lockViewTransform:(BOOL)lock {
    [self.room disableCameraTransform:lock];
}

// leave
- (void)leaveBoardWithSuccess:(void (^ _Nullable) (void))successBlock failure:(void (^ _Nullable) (void))failureBlock {
    
    self.boardViewManager = nil;

    self.isWritable = NO;
    
    if(self.room != nil) {
        [self.room disconnect:nil];
    }

    self.room = nil;
    self.whiteSDK = nil;
}

#pragma mark WhiteRoomCallbackDelegate
/**
The RoomState property in the room will trigger this callback when it changes.
*/
- (void)fireRoomStateChanged:(WhiteRoomState *_Nullable)modifyState {
    
    if(modifyState.globalState){
        id modelObj = [modifyState.globalState yy_modelToJSONObject];
        WhiteBoardStateModel *state = [WhiteBoardStateModel new];
        [state yy_modelSetWithJSON:modelObj];
        
        if ([self.delegate respondsToSelector:@selector(onWhiteBoardStateChanged:)]) {
            [self.delegate onWhiteBoardStateChanged:state];
        }
    }
    
    if (modifyState.sceneState) {

        WhiteSceneState *sceneState = self.room.sceneState;
        NSArray<WhiteScene *> *scenes = sceneState.scenes;
        NSInteger sceneIndex = sceneState.index;
        WhiteScene *scene = scenes[sceneIndex];
        if (scene.ppt) {
            CGSize size = CGSizeMake(scene.ppt.width, scene.ppt.height);
            [self moveViewToContainer:size];
        }
        
        [self.boardViewManager.pageControlView setPageIndex:sceneIndex pageCount:scenes.count];
    }
}
/** 白板失去连接回调，附带错误信息 */
- (void)fireDisconnectWithError:(NSString *)error {
    
    if ([self.delegate respondsToSelector:@selector(onWhiteBoardError:)]) {
        NSError *err = LocalError(LocalAgoraBoardErrorCode, error);
        [self.delegate onWhiteBoardError: err];
    }
}

/** 用户被远程服务器踢出房间，附带踢出原因 */
- (void)fireKickedWithReason:(NSString *)reason {
    if ([self.delegate respondsToSelector:@selector(onWhiteBoardError:)]) {
        NSError *err = LocalError(LocalAgoraBoardErrorCode, reason);
        [self.delegate onWhiteBoardError: err];
    }
}

/** 用户错误事件捕获，附带用户 id，以及错误原因 */
- (void)fireCatchErrorWhenAppendFrame:(NSUInteger)userId error:(NSString *)error {
    if ([self.delegate respondsToSelector:@selector(onWhiteBoardError:)]) {
        NSError *err = LocalError(LocalAgoraBoardErrorCode, error);
        [self.delegate onWhiteBoardError: err];
    }
}

#pragma mark WhiteCommonCallbackDelegate
/** 当sdk出现未捕获的全局错误时，会在此处对抛出 NSError 对象 */
- (void)throwError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(onWhiteBoardError:)]) {
        [self.delegate onWhiteBoardError: error];
    }
}
#pragma mark WhiteBoardColorControlDelegate
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
    [self.room setMemberState: self.whiteMemberState];
}
#pragma mark WihteBoardToolControlDelegate
- (void)onSelectToolType:(WihteBoardToolType)type {
    NSString *applianceName = @"";
    switch (type) {
        case WihteBoardToolTypeSelector:
            applianceName = ApplianceSelector;
            break;
        case WihteBoardToolTyperPencil:
            applianceName = AppliancePencil;
            break;
        case WihteBoardToolTyperText:
            applianceName = ApplianceText;
            break;
        case WihteBoardToolTyperEraser:
            applianceName = ApplianceEraser;
            break;
        case WihteBoardToolTyperColor:
        {
            BOOL hidden = self.boardViewManager.colorControlView.hidden;
            self.boardViewManager.colorControlView.hidden = !hidden;
            return;
        }
            break;
        default:
            break;
    }
    
    self.whiteMemberState.currentApplianceName = applianceName;
    [self.room setMemberState: self.whiteMemberState];
}
#pragma mark WihteBoardPageControlDelegate
- (void)selectPageIndex:(NSInteger)pageIndex completeBlock:(void (^ _Nullable)(BOOL isSuccess, NSError *error))block {
    [self.room setSceneIndex:pageIndex completionHandler:block];
}

@end
