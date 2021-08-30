//
//  AgoraWhiteBoardModels.h
//  AgoraWhiteBoard
//
//  Created by Cavan on 2021/3/19.
//  Copyright © 2021 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Whiteboard/Whiteboard.h>

NS_ASSUME_NONNULL_BEGIN

@interface AgoraWhiteBoardConfiguration : NSObject
@property (nonatomic, copy) NSString *appId;
/** 文档转网页中字体文件映射关系 */
@property (nonatomic, copy, nullable) NSDictionary *fonts;

@property (nonatomic, strong, nullable) NSDictionary *collectionStyle;
@property (nonatomic, strong, nullable) NSArray<NSString *> *boardStyles;
@end

@interface AgoraWhiteBoardJoinOptions : NSObject
@property (nonatomic, copy) NSString *boardId;
@property (nonatomic, copy) NSString *boardToken;
@end

@interface AgoraWhiteBoardTaskModel : NSObject
//@property (nonatomic, strong, readonly) NSString *resourceName;
@property (nonatomic, strong, readonly) NSString *resourceUuid;
@property (nonatomic, strong, readonly) NSString *taskUuid;
@property (nonatomic, strong, readonly) NSString *ext;
@end

@interface AgoraWhiteBoardExtAppMovement : NSObject
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@end

@interface AgoraWhiteBoardStateModel : WhiteGlobalState
@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, assign) BOOL teacherFirstLogin;
@property (nonatomic, strong) NSArray <NSString *> * _Nullable grantUsers;
@property (nonatomic, strong) NSArray <AgoraWhiteBoardTaskModel *> * _Nullable materialList;
@property (nonatomic, strong) NSDictionary * _Nullable flexBoardState;

@property (nonatomic, strong) NSDictionary * _Nullable extAppMoveTracks;
@end

@interface AgoraWhiteBoardCameraConfig : NSObject
/** 白板视角中心 X 坐标，该坐标为中心在白板内部坐标系 X 轴中的坐标 */
@property (nonatomic, assign) CGFloat centerX;
/** 白板视角中心 Y 坐标，该坐标为中心在白板内部坐标系 Y 轴中的坐标 */
@property (nonatomic, assign) CGFloat centerY;
/** 缩放比例，白板视觉中心与白板的投影距离 */
@property (nonatomic, assign) CGFloat scale;
@end

NS_ASSUME_NONNULL_END
