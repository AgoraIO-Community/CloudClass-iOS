//
//  PaintingRoomStateViewController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/10/12.
//

import Masonry
import AgoraExtApp
import AgoraEduContext
import AgoraUIBaseViews
import AgoraUIEduBaseViews

struct AgoraClassTimeInfo {
    var startTime: Int64
    var differTime: Int64
    var duration: Int64
    var closeDelay: Int64
}

class AgoraRoomStateUIController: UIViewController {
    /** 状态栏*/
    private var stateView: AgoraRoomStateBar!
    
    public var themeColor: UIColor?
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

        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] t in
            self?.updateTimeVisual()
        })
        contextPool.room.registerEventHandler(self)
        contextPool.monitor.registerMonitorEventHandler(self)
    }
}

// MARK: - Private
private extension AgoraRoomStateUIController {
    @objc func updateTimeVisual() {
        guard let info = self.timeInfo else {
            return
        }
        let interval = Date().timeIntervalSince1970 * 1000
        let realTime = Int64(interval - Double(info.differTime))

        switch self.roomState {
        case .start:
            if themeColor != nil {
                stateView.timeLabel.textColor = UIColor.white.withAlphaComponent(0.7)
            } else {
                stateView.timeLabel.textColor = UIColor(rgb: 0x677386)
            }
            let time = realTime - info.startTime
            let text = AgoraUILocalizedString("ClassAfterStartText",
                                              object: self)
            stateView.timeLabel.text = text + timeString(from: time)
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
            stateView.timeLabel.textColor = .red
            let time = realTime - info.startTime
            let text = AgoraUILocalizedString("ClassAfterStopText",
                                              object: self)
            stateView.timeLabel.text = text + timeString(from: time)
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
            stateView.timeLabel.textColor = .red
            stateView.timeLabel.text = ""
            // stop timer
            self.timer?.invalidate()
        default:
            if themeColor != nil {
                stateView.timeLabel.textColor = UIColor.white.withAlphaComponent(0.7)
            } else {
                stateView.timeLabel.textColor = UIColor(rgb: 0x677386)
            }
            let time = info.startTime - realTime
            let text = AgoraUILocalizedString("ClassBeforeStartText",
                                              object: self)
            stateView.timeLabel.text = text + timeString(from: time)
        }
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
}
// MARK: - AgoraEduRoomHandler
extension AgoraRoomStateUIController: AgoraEduRoomHandler {
    func onClassroomName(_ name: String) {
        stateView.titleLabel.text = name
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
}

extension AgoraRoomStateUIController: AgoraEduMonitorHandler {
    func onLocalNetworkQualityUpdated(quality: AgoraEduContextNetworkQuality) {
        switch quality {
        case .unknown:
            self.stateView.setNetworkState(.unknown)
        case .good:
            self.stateView.setNetworkState(.good)
        case .medium:
            self.stateView.setNetworkState(.medium)
        case .bad:
            self.stateView.setNetworkState(.bad)
        default: break
        }
    }
}
// MARK: - Creations
private extension AgoraRoomStateUIController {
    func createViews() {
        stateView = AgoraRoomStateBar(frame: .zero)
        stateView.themeColor = themeColor ?? .white
        view.addSubview(stateView)
    }
    
    func createConstrains() {
        stateView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
}
