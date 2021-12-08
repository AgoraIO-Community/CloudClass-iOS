//
//  AgoraToast.swift
//  AgoraUIEduBaseViews
//
//  Created by Jonathan on 2021/11/16.
//

import UIKit
import Masonry

@objc public enum AgoraToastType: NSInteger {
    case notice, warning, erro, success
}

public class AgoraToast: NSObject {
    
    /// 弹出Message提醒
    /// - parameter msg: 提醒内容
    /// - parameter type: 提醒框的样式
    @objc public static func toast(msg: String?,
                                   type: AgoraToastType = .notice) {
        AgoraToast.shared.toast(msg: msg,
                                type: type)
    }
    
    private static let shared = AgoraToast()
    
    private var tipsViews = [AgoraToastTipsView]()
        
    private func toast(msg: String?,
                       type: AgoraToastType = .notice) {
        guard let window = UIApplication.shared.keyWindow,
              let `msg` = msg else {
            return
        }
        let tipsView = AgoraToastTipsView(msg: msg,
                                          type: type)
        tipsView.delegate = self
        window.addSubview(tipsView)
        if tipsViews.count == 0 {
            tipsView.mas_makeConstraints { make in
                if #available(iOS 11.0, *) {
                    make?.top.equalTo()(tipsView.superview?.mas_safeAreaLayoutGuideTop)?.offset()(16)
                } else {
                    make?.top.equalTo()(16)
                }
                make?.centerX.equalTo()(0)
            }
        } else if let last = tipsViews.last {
            tipsView.mas_makeConstraints { make in
                make?.top.equalTo()(last.mas_bottom)?.offset()(5)
                make?.centerX.equalTo()(0)
            }
        }
        tipsViews.append(tipsView)
        if tipsViews.count > 5 {
            self.tipsViews.first?.stop()
        }
        tipsView.start()
    }
}
// MARK: - AgoraToastTipsViewDelegate
extension AgoraToast: AgoraToastTipsViewDelegate {
    func onDidFinishTips(_ tips: AgoraToastTipsView) {
        self.tipsViews.removeAll(where: {$0 == tips})
        if let next = self.tipsViews.first {
            next.superview?.layoutIfNeeded()
            next.mas_remakeConstraints { make in
                if #available(iOS 11.0, *) {
                    make?.top.equalTo()(next.superview?.mas_safeAreaLayoutGuideTop)?.offset()(16)
                } else {
                    make?.top.equalTo()(16)
                }
                make?.centerX.equalTo()(0)
            }
            UIView.animate(withDuration: 0.2) {
                next.superview?.layoutIfNeeded()
            }
        }
    }
}

