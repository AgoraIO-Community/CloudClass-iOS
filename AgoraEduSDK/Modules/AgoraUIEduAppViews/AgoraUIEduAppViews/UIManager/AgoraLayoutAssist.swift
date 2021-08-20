//
//  AgoraLayoutAssist.swift
//  AgoraUIEduAppViews
//
//  Created by SRS on 2021/8/16.
//

import Foundation
import AgoraUIBaseViews
import AgoraUIEduBaseViews

// 整体宽高比
let AgoraWidthHeightRatio: CGFloat = 16.0 / 9.0
// 小班课白板高度 的比例
let AgoraBoard_HeightRatio: CGFloat = 59.0 / 72.0
// 小班课单个视频宽度 的比例
let AgoraVideo_WidthRatio: CGFloat = 176.0 / 1280.0
// 小班课单个视频宽高比
let AgoraVideoWidthHeightRatio: CGFloat = 16.0 / 9.0
// 最多上台人数为7人 (包含老师)
let AgoraRenderMaxCount: CGFloat = 7.0

// 导航栏高度
let AgoraNavBarHeight: CGFloat = AgoraKitDeviceAssistant.OS.isPad ? 20 : 14

// 横屏宽度
let AgoraWidth: CGFloat = max(UIScreen.agora_width, UIScreen.agora_height)
// 横屏高度
let AgoraHeight: CGFloat = min(UIScreen.agora_width, UIScreen.agora_height)

// 最大2边的安全区域，防止旋转时序问题
fileprivate let AgoraMaxSafeSide: CGFloat = max(UIScreen.agora_safe_area_left + UIScreen.agora_safe_area_right, UIScreen.agora_safe_area_top + UIScreen.agora_safe_area_bottom)
// 横屏最多可使用宽度
fileprivate let AgoraAvailableMaxWidth: CGFloat = AgoraWidth - AgoraMaxSafeSide
// 横屏最多可使用高度
fileprivate let AgoraAvailableMaxHeight: CGFloat = AgoraHeight

// 横屏真实可使用宽度
let AgoraRealMaxWidth: CGFloat = ((AgoraAvailableMaxWidth / AgoraAvailableMaxHeight) < AgoraWidthHeightRatio) ? AgoraAvailableMaxWidth : AgoraWidthHeightRatio * AgoraAvailableMaxHeight
// 横屏真实可使用高度
let AgoraRealMaxHeight: CGFloat = AgoraRealMaxWidth / AgoraWidthHeightRatio

// 白板高度
let AgoraBoardHeight: CGFloat = AgoraRealMaxHeight * AgoraBoard_HeightRatio
let AgoraOtherHeight: CGFloat = AgoraRealMaxHeight - AgoraBoardHeight

// 小班课视频窗口宽
let AgoraVideoWidth: CGFloat = AgoraRealMaxWidth * AgoraVideo_WidthRatio
// 小班课视频窗口宽
let AgoraVideoHeight: CGFloat = AgoraVideoWidth / AgoraVideoWidthHeightRatio
// 小班课视频窗口横向的间距
let AgoraVideoGapX: CGFloat = (AgoraRealMaxWidth - (AgoraRenderMaxCount * AgoraVideoWidth)) / (AgoraRenderMaxCount - 1.0)
// 小班课视频窗口竖向的间距
let AgoraVideoGapY: CGFloat = (AgoraOtherHeight - AgoraNavBarHeight - AgoraVideoHeight) * 0.5

@objcMembers public class AgoraLayoutAssist: NSObject {
    public static func agoraRealMaxWidth() -> CGFloat {
        return AgoraRealMaxWidth
    }
    
    public static func agoraRealMaxHeight() -> CGFloat {
        return AgoraRealMaxHeight
    }
}
