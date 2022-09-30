//
//  RoomListShareAlertController.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/9/13.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit
import AgoraUIBaseViews

struct FcrShareLink {
    public static func shareLinkWith(roomId: String) -> String {
        let owner = FcrUserInfoPresenter.shared.nickName.urlEncoded
        let room = roomId.urlEncoded
        let dict = [
            "owner": owner,
            "roomId": room,
            "region": FcrEnvironment.shared.region.rawValue
        ]
        let json = dict.jsonString()
        let sc = json?.base64Encoded ?? ""
//        var version = UIApplication.shared.version ?? ""
//        var nums = version.split(separator: ".")
//        nums.removeLast()
//        nums.append("x")
//        version = nums.joined(separator: ".")
        let version = "2.8.x"
        var baseURL = "https://solutions-apaas.agora.io/apaas/app/prod/"
        if FcrEnvironment.shared.environment != .pro {
            baseURL = "https://solutions-apaas.agora.io/apaas/app/test/release_"
        }
        let shareLink = baseURL + version + "/index.html/#/invite?sc=" + sc
        return shareLink
    }
}
class RoomListShareAlertController: UIViewController {
    
    static func show(in viewController: UIViewController,
                     roomId: String,
                     complete: (() -> Void)?) {
        let vc = RoomListShareAlertController()
        vc.complete = complete
        vc.roomId = roomId
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        viewController.present(vc,
                               animated: true)
    }
    
    private var complete: (() -> Void)?
    
    private let contentView = UIView()
    
    private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    private let alertBg = UIImageView(image: UIImage(named: "fcr_alert_bg"))
        
    private let copyLinkButton = UIButton(type: .custom)
    
    private let copyTitleLabel = UILabel()
    
    private let cancelButton = UIButton(type: .custom)
    
    private var roomId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        // Do any additional setup after loading the view.
        createViews()
        createConstrains()
    }
}
// MARK: - Actions
private extension RoomListShareAlertController {
    @objc func onClickCancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc func onClickCopyLink(_ sender: UIButton) {
        guard let roomId = roomId else {
            return
        }
        UIPasteboard.general.string = FcrShareLink.shareLinkWith(roomId: roomId)
        AgoraToast.toast(message: "fcr_sharelink_tips_roomid".ag_localized(),
                         type: .notice)
        dismiss(animated: true)
        complete?()
    }
}
// MARK: - Creations
private extension RoomListShareAlertController {
    func createViews() {
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        contentView.layer.cornerRadius = 40
        contentView.clipsToBounds = true
        view.addSubview(contentView)
        
        contentView.addSubview(effectView)
        contentView.addSubview(alertBg)
        
        copyLinkButton.setImage(UIImage(named: "fcr_room_list_copy_link"),
                                for: .normal)
        copyLinkButton.addTarget(self,
                                 action: #selector(onClickCopyLink(_:)),
                                 for: .touchUpInside)
        contentView.addSubview(copyLinkButton)
        
        copyTitleLabel.font = UIFont.systemFont(ofSize: 12)
        copyTitleLabel.textColor = UIColor.black
        copyTitleLabel.text = "fcr_room_list_copy_link".ag_localized()
        contentView.addSubview(copyTitleLabel)
        
        cancelButton.setTitle("fcr_alert_cancel".ag_localized(),
                              for: .normal)
        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cancelButton.addTarget(self,
                               action: #selector(onClickCancel(_:)),
                               for: .touchUpInside)
        cancelButton.setTitleColor(.black,
                                   for: .normal)
        cancelButton.layer.cornerRadius = 23
        cancelButton.clipsToBounds = true
        cancelButton.backgroundColor = UIColor(hex: 0xF8F8F8)
        contentView.addSubview(cancelButton)
    }
    
    func createConstrains() {
        contentView.mas_makeConstraints { make in
            make?.left.equalTo()(16)
            make?.right.bottom().equalTo()(-16)
            make?.height.equalTo()(231)
        }
        effectView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        alertBg.mas_makeConstraints { make in
            make?.top.left().equalTo()(0)
        }
        copyLinkButton.mas_makeConstraints { make in
            make?.top.equalTo()(35)
            make?.left.equalTo()(28)
        }
        copyTitleLabel.mas_makeConstraints { make in
            make?.centerX.equalTo()(copyLinkButton)
            make?.top.equalTo()(copyLinkButton.mas_bottom)?.offset()(9)
        }
        cancelButton.mas_makeConstraints { make in
            make?.left.equalTo()(27)
            make?.right.equalTo()(-27)
            make?.bottom.equalTo()(-30)
            make?.height.equalTo()(46)
        }
    }
}
