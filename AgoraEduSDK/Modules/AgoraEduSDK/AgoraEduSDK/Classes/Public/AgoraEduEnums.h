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
    // 准备完成
    AgoraEduEventReady = 1,
    // 已经销毁
    AgoraEduEventDestroyed = 2,
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
    // 小班课
    AgoraEduRoomTypeSmall = 1,
    // 大班课
    AgoraEduRoomTypeBig = 2,
};

NS_ASSUME_NONNULL_END
