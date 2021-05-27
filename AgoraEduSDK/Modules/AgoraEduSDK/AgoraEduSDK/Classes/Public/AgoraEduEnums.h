//
//  AgoraEduEnums.h
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// 事件类型
typedef NS_ENUM(NSInteger, AgoraEduEvent) {
    // 失败
    AgoraEduEventFailed = 0,
    // 准备完成
    AgoraEduEventReady,
    // 已经销毁
    AgoraEduEventDestroyed,
    // Forbidden
    AgoraEduEventForbidden,
};

// 角色类型
typedef NS_ENUM(NSInteger, AgoraEduRoleType) {
    // 学生
    AgoraEduRoleTypeStudent = 2,
};

// 教室类型
typedef NS_ENUM(NSInteger, AgoraEduRoomType) {
    // 1V1
    AgoraEduRoomType1V1 = 0,
    // 大班课
    AgoraEduRoomTypeLecture = 2,
    // 小班课
    AgoraEduRoomTypeSmall = 4,
};

//
//typedef NS_ENUM(NSInteger, AgoraExtAppProvider) {
//    // 1V1
//    AgoraExtAppProvider = 0,
//    // 大班课
//    AgoraExtAppProvider = 2,
//    // 小班课
//    AgoraExtAppProvider = 4,
//};

NS_ASSUME_NONNULL_END
