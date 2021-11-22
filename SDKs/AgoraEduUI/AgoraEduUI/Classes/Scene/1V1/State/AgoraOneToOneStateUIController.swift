//
//  AgoraOneToOneStateUIController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/11/15.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext
import Masonry
import UIKit

protocol AgoraOneToOneStateUIControllerDelegate: NSObjectProtocol {
    func onSettingSelected(isSelected: Bool)
}

class AgoraOneToOneStateUIController: UIViewController {
    
    public weak var delegate: AgoraOneToOneStateUIControllerDelegate?
    
    private var netStateView: UIImageView!
    
    private var titleLabel: UILabel!
    
    private var lineView: UIView!
    
    private var timeLabel: UILabel!
    
    private var settingButton: UIButton!
    /** SDK环境*/
    private var contextPool: AgoraEduContextPool!
    /** 房间状态*/
    private var roomState: AgoraEduContextClassState = .default {
        didSet {
            if roomState != oldValue, roomState == .close {
                classOverAlert()
            }
        }
    }
    /** 房间计时器*/
    private var timer: Timer?
    /** 房间时间信息*/
    private var timeInfo: AgoraClassTimeInfo?
    
    deinit {
        self.timer?.invalidate()
        self.timer = nil
        print("\(#function): \(self.classForCoder)")
    }
    
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
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0,
                                          repeats: true,
                                          block: { [weak self] _ in
            self?.updateTimeVisual()
        })
        contextPool.room.registerEventHandler(self)
    }
    
    public func deSelect() {
        settingButton.isSelected = false
        settingButton.imageView?.tintColor = UIColor(hex: 0x7B88A0)
        settingButton.backgroundColor = .white
    }
}
// MARK: - Private
extension AgoraOneToOneStateUIController {
    func classOverAlert() {
        let buttonLabel = AgoraAlertLabelModel()
        buttonLabel.text = AgoraKitLocalizedString("SureText")
        let button = AgoraAlertButtonModel()
        button.titleLabel = buttonLabel
        button.tapActionBlock = { [weak self] (index) -> Void in
            self?.contextPool.room.leaveRoom()
        }
        AgoraUtils.showAlert(imageModel: nil,
                             title: AgoraKitLocalizedString("ClassOverNoticeText"),
                             message: AgoraKitLocalizedString("ClassOverText"),
                             btnModels: [button])
    }
    
    func timeString(from interval: Int64) -> String {
        let time = interval > 0 ? (interval / 1000) : 0
        let hourInt = time / 3600
        let minuteInt = (time - 3600 * hourInt) / 60
        let secondInt = time % 60
        
        let hourString = NSString(format: "%02d", hourInt) as String
        let minuteString = NSString(format: "%02d", minuteInt) as String
        let secondString = NSString(format: "%02d", secondInt) as String
        
        let hourText = AgoraKitLocalizedString("ClassTimeHourText")
        let minuteText = AgoraKitLocalizedString("ClassTimeMinuteText")
        let secondText = AgoraKitLocalizedString("ClassTimeSecondText")
        if hourInt > 0 {
            return "\(hourString)\(hourText)\(minuteString)\(minuteText)\(secondString)\(secondText)"
        } else {
            return "\(minuteString)\(minuteText)\(secondString)\(secondText)"
        }
    }
}

// MARK: - Actions
extension AgoraOneToOneStateUIController {
    @objc func onClickSetting(_ sender: UIButton) {
        AgoraToast.toast(msg: "aaaaaaaaa")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            AgoraLoading.hide()
        }
        return
        sender.isSelected = !sender.isSelected
        delegate?.onSettingSelected(isSelected: sender.isSelected)
        if sender.isSelected {
            settingButton.imageView?.tintColor = .white
            settingButton.backgroundColor = UIColor(hex: 0x357BF6)
        } else {
            settingButton.imageView?.tintColor = UIColor(hex: 0x7B88A0)
            settingButton.backgroundColor = .white
        }
    }
    
    func updateTimeVisual() {
        guard let info = self.timeInfo else {
            return
        }
        let interval = Date().timeIntervalSince1970 * 1000
        let realTime = Int64(interval - Double(info.differTime))
        
        switch self.roomState {
        case .start:
            timeLabel.textColor = UIColor(rgb: 0x677386)
            let time = realTime - info.startTime
            let text = AgoraUILocalizedString("ClassAfterStartText",
                                              object: self)
            timeLabel.text = text + timeString(from: time)
            // 事件
            let countDown = info.closeDelay + info.duration - time
            if countDown == 5 * 60 + info.closeDelay {
                let strStart = AgoraUILocalizedString("ClassEndWarningStartText",
                                                      object: self)
                let strMid = "5"
                let strEnd = AgoraUILocalizedString("ClassEndWarningEndText",
                                                    object: self)
                AgoraToast.toast(msg: strStart + strMid + strEnd)
            }
        case .end:
            timeLabel.textColor = .red
            let time = realTime - info.startTime
            let text = AgoraUILocalizedString("ClassAfterStopText",
                                              object: self)
            timeLabel.text = text + timeString(from: time)
            // 事件
            let countDown = info.closeDelay + info.duration - time
            if countDown == info.closeDelay {
                let strStart = AgoraUILocalizedString("ClassCloseWarningStartText",
                                                      object: self)
                let minNum = Int(info.closeDelay / 60)
                let strMid = "\(minNum)"
                let strMin = AgoraUILocalizedString("ClassCloseWarningEnd2Text",
                                                    object: self)
                let strEnd = AgoraUILocalizedString("ClassCloseWarningEndText",
                                                    object: self)
                AgoraToast.toast(msg: strStart + strMid + strMin + strEnd)
            } else if countDown == 60 {
                let strStart = AgoraUILocalizedString("ClassCloseWarningStart2Text",
                                                      object: self)
                let strMid = "1"
                let strEnd = AgoraUILocalizedString("ClassCloseWarningEnd2Text",
                                                    object: self)
                AgoraToast.toast(msg: strStart + strMid + strEnd)
            }
        case .close:
            timeLabel.textColor = .red
            timeLabel.text = ""
            // stop timer
            self.timer?.invalidate()
        default:
            timeLabel.textColor = UIColor(rgb: 0x677386)
            let time = info.startTime - realTime
            let text = AgoraUILocalizedString("ClassBeforeStartText",
                                              object: self)
            timeLabel.text = text + timeString(from: time)
        }
    }
}

extension AgoraOneToOneStateUIController: AgoraEduRoomHandler {
    func onClassroomName(_ name: String) {
        titleLabel.text = name
    }
    
    func onClassState(_ state: AgoraEduContextClassState) {
        self.roomState = state
    }
    
    func onClassTimeInfo(startTime: Int64,
                         differTime: Int64,
                         duration: Int64,
                         closeDelay: Int64) {
        self.timeInfo = AgoraClassTimeInfo(startTime: startTime,
                                          differTime: differTime,
                                          duration: duration * 1000,
                                          closeDelay: closeDelay * 1000)
    }
    
    func onNetworkQuality(_ quality: AgoraEduContextNetworkQuality) {
        switch quality {
        case .unknown:
            netStateView.image = UIImage.ag_imageNamed("ic_network_unknow",
                                                       in: "AgoraEduUI")
        case .good:
            netStateView.image = UIImage.ag_imageNamed("ic_network_good",
                                                       in: "AgoraEduUI")
        case .medium:
            netStateView.image = UIImage.ag_imageNamed("ic_network_medium",
                                                       in: "AgoraEduUI")
        case .bad:
            netStateView.image = UIImage.ag_imageNamed("ic_network_bad",
                                                       in: "AgoraEduUI")
        default: break
        }
    }
}

// MARK: - Creaions
private extension AgoraOneToOneStateUIController {
    func createViews() {
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(hex: 0xECECF1)?.cgColor
        
        netStateView = UIImageView(image: UIImage.ag_imageNamed("ic_network_unknow",
                                                                in: "AgoraEduUI"))
        view.addSubview(netStateView)
        
        lineView = UIView(frame: .zero)
        lineView.backgroundColor = UIColor(hex: 0xECECF1)
        view.addSubview(lineView)
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textColor = UIColor(rgb: 0x191919)
        view.addSubview(titleLabel)
        
        timeLabel = UILabel()
        timeLabel.font = UIFont.systemFont(ofSize: 13)
        timeLabel.textColor = UIColor(rgb: 0x677386)
        view.addSubview(timeLabel)
        
        settingButton = UIButton(type: .custom)
        if let settingIMG = UIImage.ag_imageNamed("ic_func_setting",
                                                  in: "AgoraEduUI")?
            .withRenderingMode(.alwaysTemplate) {
            settingButton.setImageForAllStates(settingIMG)
        }
        settingButton.imageView?.tintColor = UIColor(rgb: 0x7B88A0)
        settingButton.addTarget(self, action: #selector(onClickSetting(_:)),
                                for: .touchUpInside)
        settingButton.layer.cornerRadius = AgoraFit.scale(34) * 0.5
        settingButton.clipsToBounds = true
        view.addSubview(settingButton)
    }
    
    func createConstrains() {
        netStateView.mas_makeConstraints { make in
            if #available(iOS 11.0, *) {
                make?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)?.offset()(10)
            } else {
                make?.left.equalTo()(self.view)?.offset()(10)
            }
            make?.width.height().equalTo()(20)
            make?.centerY.equalTo()(0)
        }
        lineView.mas_makeConstraints { make in
            make?.centerX.centerY().equalTo()(0)
            make?.width.equalTo()(1)
            make?.height.equalTo()(16)
        }
        titleLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(0)
            make?.right.equalTo()(lineView.mas_left)?.offset()(-20)
        }
        timeLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(0)
            make?.left.equalTo()(lineView.mas_right)?.offset()(20)
        }
        settingButton.mas_makeConstraints { make in
            if #available(iOS 11.0, *) {
                make?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
            } else {
                make?.right.equalTo()(0)
            }
            make?.centerY.equalTo()(0)
            make?.width.height().equalTo()(AgoraFit.scale(34))
        }
    }
}
