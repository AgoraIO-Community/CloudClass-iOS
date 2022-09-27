//
//  RoomListJoinAlertController.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/9/14.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit
import AgoraUIBaseViews

private class JoinRoomTextField: UITextField {
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 20, y: 0, width: 75, height: bounds.height)
    }
}

class RoomListJoinAlertController: UIViewController {
    
    static func show(in viewController: UIViewController,
                     inputModel: RoomInputInfoModel,
                     complete: ((RoomInputInfoModel) -> Void)?) {
        let vc = RoomListJoinAlertController()
        vc.inputModel = inputModel
        vc.complete = complete
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        viewController.present(vc,
                               animated: true)
    }
    
    private var complete: ((RoomInputInfoModel) -> Void)?
    
    private let contentView = UIView()
    
    private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    private let alertBg = UIImageView(image: UIImage(named: "fcr_alert_bg"))
    
    private let titleLabel = UILabel()
    
    private let cardView = UIView()
    
    private let idTextField = JoinRoomTextField()
    
    private let lineView = UIView()
        
    private let nameTextField = JoinRoomTextField()
    
    private let roleTitleLabel = UILabel()
    
    private let studentButton = UIButton(type: .custom)
    
    private let teacherButton = UIButton(type: .custom)
    
    private let closeButton = UIButton(type: .custom)
    
    private let submitButton = UIButton(type: .custom)
    
    private let cancelButton = UIButton(type: .custom)
    
    private var inputModel: RoomInputInfoModel?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        // Do any additional setup after loading the view.
        createViews()
        createConstrains()
        registerNoti()
        setup()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        super.touchesBegan(touches,
                           with: event)
        
        UIApplication.shared.keyWindow?.endEditing(true)
    }
    
    func registerNoti() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onKeyBoardShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onKeyBoardHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
}
// MARK: - Actions
private extension RoomListJoinAlertController {
    func setup() {
        idTextField.text = inputModel?.roomId
        nameTextField.text = FcrUserInfoPresenter.shared.nickName
        
        if inputModel?.roleType == 0 {
            teacherButton.isSelected = true
            studentButton.isSelected = false
        } else {
            teacherButton.isSelected = false
            studentButton.isSelected = true
        }
    }
    
    @objc func onClickCancel(_ sender: UIButton) {
        UIApplication.shared.keyWindow?.endEditing(true)
        dismiss(animated: true)
        complete = nil
    }
    
    @objc func onClickSubmmit(_ sender: UIButton) {
        guard let model = inputModel,
              let roomId = idTextField.text,
              roomId.count > 0
        else {
            AgoraToast.toast(message: "fcr_joinroom_tips_roomid_empty".ag_localized(),
                             type: .error)
            return
        }
        guard let name = nameTextField.text,
              name.count > 0
        else {
            AgoraToast.toast(message: "fcr_joinroom_tips_username_empty".ag_localized(),
                             type: .error)
            return
        }
        FcrUserInfoPresenter.shared.nickName = name
        model.roomId = roomId
        model.userName = name
        complete?(model)
        
        dismiss(animated: true)
        complete = nil
    }
    
    @objc func onClickTeacher(_ sender: UIButton) {
        sender.isSelected = true
        studentButton.isSelected = false
        inputModel?.roleType = 1
    }
    
    @objc func onClickStudent(_ sender: UIButton) {
        sender.isSelected = true
        teacherButton.isSelected = false
        inputModel?.roleType = 2
    }
    
    @objc func onKeyBoardShow(_ sender: NSNotification) {
        guard let userInfo = sender.userInfo,
              let value = userInfo["UIKeyboardBoundsUserInfoKey"] as? NSValue
        else {
            return
        }
        let height = value.cgRectValue.size.height
        var contentHeight: CGFloat = 446
        if idTextField.isEditing {
            contentHeight = idTextField.frame.maxY + height + 40
        } else if nameTextField.isEditing {
            contentHeight = nameTextField.frame.maxY + height
        }
        contentView.mas_updateConstraints { make in
            make?.height.equalTo()(contentHeight)
        }
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func onKeyBoardHide(_ sender: NSNotification) {
        contentView.mas_updateConstraints { make in
            make?.height.equalTo()(446)
        }
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}
// MARK: - UITextField Call Bakc
extension RoomListJoinAlertController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        if textField == idTextField {
            if text.count > 50 && string.count != 0 {
                return false
            }
            let regex = "^[0-9]*$"
            let format = NSPredicate(format: "SELF MATCHES %@" , regex).evaluate(with: string)
            return format
        } else if textField == nameTextField {
            if text.count > 50 && string.count != 0 {
                return false
            }
            return true
        } else {
            return true
        }
    }
}
// MARK: - Creations
private extension RoomListJoinAlertController {
    func createViews() {
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        contentView.layer.cornerRadius = 40
        contentView.clipsToBounds = true
        view.addSubview(contentView)
        
        contentView.addSubview(effectView)
        contentView.addSubview(alertBg)
        
        titleLabel.textColor = .black
        titleLabel.text = "fcr_room_join_title".ag_localized()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        contentView.addSubview(titleLabel)
        
        cardView.backgroundColor = UIColor.white
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        contentView.addSubview(cardView)
        
        lineView.backgroundColor = UIColor(hex: 0xEFEFEF)
        cardView.addSubview(lineView)
        
        let idTitleLabel = UILabel()
        idTitleLabel.text = "fcr_room_join_room_id".ag_localized()
        idTitleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        idTitleLabel.textColor = UIColor.black
        
        idTextField.placeholder = "fcr_room_join_room_id_ph".ag_localized()
        idTextField.leftViewMode = .always
        idTextField.leftView = idTitleLabel
        idTextField.font = UIFont.boldSystemFont(ofSize: 15)
        idTextField.textColor = UIColor.black
        idTextField.delegate = self
        idTextField.returnKeyType = .done
        idTextField.keyboardType = .numberPad
        contentView.addSubview(idTextField)
        
        let nameTitleLabel = UILabel()
        nameTitleLabel.text = "fcr_room_join_room_name".ag_localized()
        nameTitleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        nameTitleLabel.textColor = UIColor.black
        
        nameTextField.placeholder = "fcr_room_join_room_name_ph".ag_localized()
        nameTextField.leftViewMode = .always
        nameTextField.leftView = nameTitleLabel
        nameTextField.font = UIFont.boldSystemFont(ofSize: 15)
        nameTextField.textColor = UIColor.black
        nameTextField.delegate = self
        nameTextField.returnKeyType = .done
        contentView.addSubview(nameTextField)
        
        roleTitleLabel.text = "fcr_room_join_room_role".ag_localized()
        roleTitleLabel.font = UIFont.systemFont(ofSize: 15)
        roleTitleLabel.textColor = UIColor(hex: 0xBDBEC6)
        contentView.addSubview(roleTitleLabel)
        
        studentButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        studentButton.setTitleForAllStates("fcr_room_join_room_role_student".ag_localized())
        studentButton.setTitleColor(.white,
                                    for: .selected)
        studentButton.setTitleColor(.black,
                                    for: .normal)
        let normalImg = UIImage(color: .white,
                                size: CGSize(width: 1, height: 1))
        studentButton.setBackgroundImage(normalImg,
                                         for: .normal)
        let selectImg = UIImage(color: UIColor(hex: 0x357BF6) ?? .black,
                                size: CGSize(width: 1, height: 1))
        studentButton.setBackgroundImage(selectImg,
                                         for: .selected)
        studentButton.layer.cornerRadius = 10
        studentButton.clipsToBounds = true
        studentButton.addTarget(self,
                                action: #selector(onClickStudent(_:)),
                                for: .touchUpInside)
        contentView.addSubview(studentButton)
        
        teacherButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        teacherButton.setTitleForAllStates("fcr_room_join_room_role_teacher".ag_localized())
        teacherButton.setTitleColor(.white,
                                    for: .selected)
        teacherButton.setTitleColor(.black,
                                    for: .normal)
        teacherButton.setBackgroundImage(normalImg,
                                         for: .normal)
        teacherButton.setBackgroundImage(selectImg,
                                         for: .selected)
        teacherButton.layer.cornerRadius = 10
        teacherButton.clipsToBounds = true
        teacherButton.addTarget(self,
                                action: #selector(onClickTeacher(_:)),
                                for: .touchUpInside)
        contentView.addSubview(teacherButton)
        
        closeButton.setImage(UIImage(named: "fcr_room_create_alert_cancel"),
                             for: .normal)
        closeButton.addTarget(self,
                              action: #selector(onClickCancel(_:)),
                              for: .touchUpInside)
        contentView.addSubview(closeButton)
        
        submitButton.setTitle("fcr_alert_sure".ag_localized(),
                              for: .normal)
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        submitButton.addTarget(self,
                               action: #selector(onClickSubmmit(_:)),
                               for: .touchUpInside)
        submitButton.setTitleColor(.white,
                                   for: .normal)
        submitButton.layer.cornerRadius = 23
        submitButton.clipsToBounds = true
        submitButton.backgroundColor = UIColor(hex: 0x357BF6)
        contentView.addSubview(submitButton)
        
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
            make?.height.equalTo()(446)
        }
        effectView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        alertBg.mas_makeConstraints { make in
            make?.top.left().equalTo()(0)
        }
        titleLabel.mas_makeConstraints { make in
            make?.left.top().equalTo()(24)
        }
        cardView.mas_makeConstraints { make in
            make?.top.equalTo()(titleLabel.mas_bottom)?.offset()(28)
            make?.left.equalTo()(15)
            make?.right.equalTo()(-15)
            make?.height.equalTo()(120)
        }
        lineView.mas_makeConstraints { make in
            make?.center.width().equalTo()(cardView)
            make?.height.equalTo()(1)
        }
        idTextField.mas_makeConstraints { make in
            make?.left.top().right().equalTo()(cardView)
            make?.bottom.equalTo()(lineView)
        }
        nameTextField.mas_makeConstraints { make in
            make?.left.bottom().right().equalTo()(cardView)
            make?.top.equalTo()(lineView)
        }
        roleTitleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(cardView.mas_bottom)?.offset()(20)
            make?.left.equalTo()(37)
        }
        teacherButton.mas_makeConstraints { make in
            make?.top.equalTo()(roleTitleLabel.mas_bottom)?.offset()(12)
            make?.left.equalTo()(17)
            make?.right.equalTo()(contentView.mas_centerX)?.offset()(-6)
            make?.height.equalTo()(45)
        }
        studentButton.mas_makeConstraints { make in
            make?.top.equalTo()(roleTitleLabel.mas_bottom)?.offset()(12)
            make?.right.equalTo()(-17)
            make?.left.equalTo()(contentView.mas_centerX)?.offset()(6)
            make?.height.equalTo()(45)
        }
        closeButton.mas_makeConstraints { make in
            make?.top.equalTo()(15)
            make?.right.equalTo()(-15)
        }
        submitButton.mas_makeConstraints { make in
            make?.bottom.equalTo()(-30)
            make?.right.equalTo()(-12)
            make?.height.equalTo()(46)
            make?.width.equalTo()(190)
        }
        cancelButton.mas_makeConstraints { make in
            make?.centerY.equalTo()(submitButton)
            make?.right.equalTo()(submitButton.mas_left)?.offset()(-15)
            make?.height.equalTo()(46)
            make?.width.equalTo()(110)
        }
    }
}
