//
//  RoomListShareAlertController.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/9/13.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit

class RoomListShareAlertController: UIViewController {
    
    static func show(in viewController: UIViewController,
                     roomId: String,
                     complete: (() -> Void)?) {
        let vc = RoomListShareAlertController()
        vc.complete = complete
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        viewController.present(vc,
                               animated: true)
    }
    
    private var complete: (() -> Void)?
    
    private let contentView = UIView()
    
    private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        
    private let copyLinkButton = UIButton(type: .custom)
    
    private let cancelButton = UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()

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
        cancelButton.mas_makeConstraints { make in
            make?.left.equalTo()(27)
            make?.right.equalTo()(-27)
            make?.bottom.equalTo()(-30)
            make?.height.equalTo()(46)
        }
    }
}
