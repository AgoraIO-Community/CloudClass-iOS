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

// note to modify AgoraWhiteGlobalStateModel
@interface AgoraWhiteBoardStateModel : NSObject
@property (nonatomic, assign, readonly) BOOL isFullScreen;
@property (nonatomic, assign, readonly) BOOL teacherFirstLogin;
@property (nonatomic, strong, readonly) NSArray <NSString *> * _Nullable grantUsers;
@property (nonatomic, strong, readonly) NSArray <AgoraWhiteBoardTaskModel *> * _Nullable materialList;
@end

@interface AgoraWhiteGlobalStateTaskModel : NSObject
@property (nonatomic, strong) NSString *resourceUuid;
@property (nonatomic, strong) NSString *taskUuid;
@property (nonatomic, strong) NSString *ext;
@end

@interface AgoraWhiteGlobalStateModel : WhiteGlobalState
@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, assign) BOOL teacherFirstLogin;
@property (nonatomic, strong) NSArray <NSString *> *grantUsers;
@property (nonatomic, strong) NSArray <AgoraWhiteGlobalStateTaskModel *> *materialList;
@end

NS_ASSUME_NONNULL_END
