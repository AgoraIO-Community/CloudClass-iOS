//
//  AgoraColorGroup.swift
//  AgoraClassroomSDK_iOS
//
//  Created by Cavan on 2022/3/17.
//

import AgoraUIBaseViews
import UIKit

@objc public enum AgoraUIMode: Int {
    case agoraLight
    case agoraDark
}

fileprivate var Mode: AgoraUIMode = .agoraLight

class AgoraUIGroup {
    private(set) lazy var frame = AgoraFrameGroup()
    private(set) lazy var font  = AgoraFontGroup()
    
    func setMode(_ mode: AgoraUIMode) {
        Mode = mode
        FcrColorGroup.setMode(mode)
    }
}

struct AgoraFrameGroup {
    init() {
        self.mode = Mode
    }
    
    fileprivate var mode: AgoraUIMode
    
    // corner radius
    var fcr_window_corner_radius: CGFloat = 2
    var fcr_toast_corner_radius: CGFloat = 4
    var fcr_button_corner_radius: CGFloat = 6
    var fcr_alert_corner_radius: CGFloat = 12
    var fcr_round_container_corner_radius: CGFloat = 16
    var fcr_square_container_corner_radius: CGFloat = 10
    
    // border width
    var fcr_border_width: CGFloat = 1
    
    // alert side spacing
    var fcr_alert_side_spacing: CGFloat = 30
}

class AgoraFontGroup {
    init() {
        self.mode = Mode
    }
    
    fileprivate var mode: AgoraUIMode
    
    var fcr_font17: UIFont = .systemFont(ofSize: 17)
    var fcr_font14: UIFont = .systemFont(ofSize: 14)
    var fcr_font13: UIFont = .systemFont(ofSize: 13)
    var fcr_font12: UIFont = .systemFont(ofSize: 12)
    var fcr_font11: UIFont = .systemFont(ofSize: 11)
    var fcr_font10: UIFont = .systemFont(ofSize: 10)
    var fcr_font9: UIFont  = .systemFont(ofSize: 9)
}
