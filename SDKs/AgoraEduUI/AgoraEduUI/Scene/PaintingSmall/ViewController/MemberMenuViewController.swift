//
//  MemberMenuViewController.swift
//  AgoraEduUI
//
//  Created by HeZhengQing on 2021/9/28.
//

import UIKit
import SnapKit
import AgoraEduContext

class MemberMenuViewController: UIViewController {
    
    var contentView: UIStackView!
    
    var micButton: UIButton!
    
    var cameraButton: UIButton!
    
    var stageButton: UIButton!
    
    var signButton: UIButton!
    
    var priseButton: UIButton!
    
    var contextPool: AgoraEduContextPool!
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        contextPool = context
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
        createConstrains()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.layer.cornerRadius = self.view.bounds.height * 0.5
    }
}
// MARK: - Actions
extension MemberMenuViewController {
    func onClickMic(_ sender: UIButton) {
        
    }
    
    func onClickCamera(_ sender: UIButton) {
        
    }
    
    func onClickStage(_ sender: UIButton) {
        
    }
    
    func onClickSign(_ sender: UIButton) {
        
    }
    
    func onClickPrise(_ sender: UIButton) {
        
    }
}
// MARK: - Creations
private extension MemberMenuViewController {
    func createViews() {
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor(rgb:0x2F4192).withAlphaComponent(0.15).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 6
        
        contentView = UIStackView()
        contentView.backgroundColor = .clear
        contentView.axis = .horizontal
        contentView.spacing = 2
        contentView.distribution = .equalSpacing
        contentView.alignment = .center
        contentView.backgroundColor = .white
        view.addSubview(contentView)
        
        micButton = UIButton(type: .custom)
        micButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        micButton.setBackgroundImage(AgoraUIImage(object: self, name: "ic_member_menu_mic"), for: .normal)
        contentView.addArrangedSubview(micButton)
        
        cameraButton = UIButton(type: .custom)
        cameraButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        cameraButton.setBackgroundImage(AgoraUIImage(object: self, name: "ic_member_menu_camera"), for: .normal)
        contentView.addArrangedSubview(cameraButton)
        
        stageButton = UIButton(type: .custom)
        stageButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        stageButton.setBackgroundImage(AgoraUIImage(object: self, name: "ic_member_menu_stage"), for: .normal)
        contentView.addArrangedSubview(stageButton)
        
        signButton = UIButton(type: .custom)
        signButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        signButton.setBackgroundImage(AgoraUIImage(object: self, name: "ic_member_menu_auth"), for: .normal)
        contentView.addArrangedSubview(signButton)
        
        priseButton = UIButton(type: .custom)
        priseButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        priseButton.setBackgroundImage(AgoraUIImage(object: self, name: "ic_member_menu_star"), for: .normal)
        contentView.addArrangedSubview(priseButton)
    }
    
    func createConstrains() {
        contentView.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.top.bottom.equalToSuperview()
        }
    }
}
