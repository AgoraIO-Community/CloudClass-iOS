//
//  AkBoardUIController.swift
//  AgoraClassroomSDK_iOS
//
//  Created by LYY on 2022/3/10.
//

import AgoraEduContext
import AgoraWidget

class AkBoardUIController: UIViewController {
    var boardWidget: AgoraBaseWidget?
    var contextPool: AgoraEduContextPool!
    
    private var localGranted = false {
        didSet {
            guard localGranted != oldValue else {
                return
            }
            if !localGranted {
                AgoraToast.toast(msg: "fcr_netless_board_ungranted".agedu_localized(),
                                 type: .error)
            } else if localGranted,
                        contextPool.user.getLocalUserInfo().userRole != .teacher {
                AgoraToast.toast(msg: "fcr_netless_board_granted".agedu_localized(),
                                 type: .notice)
            }
        }
    }
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        contextPool = context
        
        let ui = AgoraUIGroup()
        view.backgroundColor = ui.color.board_bg_color
        view.layer.borderWidth = ui.frame.board_border_width
        view.layer.borderColor = ui.color.render_cell_border_color
        view.layer.cornerRadius = ui.frame.board_corner_radius
        
        contextPool.room.registerRoomEventHandler(self)
        contextPool.media.registerMediaEventHandler(self)
        contextPool.widget.add(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        UIApplication.shared.windows[0].endEditing(true)
    }
}

// MARK: - private
private extension AkBoardUIController {
    func initBoardWidget() {
        if let boardConfig = contextPool.widget.getWidgetConfig(kBoardWidgetId) {
            let boardWidget = contextPool.widget.create(boardConfig)
            contextPool.widget.add(self,
                                   widgetId: boardConfig.widgetId)
            view.isUserInteractionEnabled = true
            view.addSubview(boardWidget.view)
            self.boardWidget = boardWidget

            var borderWidth = AgoraFrameGroup().board_border_width
            boardWidget.view.mas_makeConstraints { make in
                make?.left.top().equalTo()(borderWidth)
                make?.right.bottom().equalTo()(-borderWidth)
            }
        }
    }
    
    func deinitBoardWidget() {
        self.boardWidget?.view.removeFromSuperview()
        self.boardWidget = nil
        contextPool.widget.remove(self,
                                  widgetId: kBoardWidgetId)
    }
    
    func joinBoard() {
        if let message = AgoraBoardWidgetSignal.JoinBoard.toMessageString() {
            contextPool.widget.sendMessage(toWidget: kBoardWidgetId,
                                           message: message)
        }
    }
    
    func handleBoardPhase(_ phase: AgoraBoardWidgetRoomPhase) {
        switch phase {
        case .Disconnected :
            break
        default:
            break
        }
    }
    
    func handleAudioMixing(_ data: AgoraBoardWidgetAudioMixingRequestData) {
        var contextError: AgoraEduContextError?
        switch data.requestType {
        case .start:
            contextError = contextPool.media.startAudioMixing(filePath: data.filePath,
                                                              loopback: data.loopback,
                                                              replace: data.replace,
                                                              cycle: data.cycle)
        case .stop:
            contextError = contextPool.media.stopAudioMixing()
        case .setPosition:
            contextError = contextPool.media.setAudioMixingPosition(position: data.position)
        default:
            break
        }
        
        if let error = contextError,
           let message = AgoraBoardWidgetSignal.AudioMixingStateChanged(AgoraBoardWidgetAudioMixingChangeData(stateCode: 714,
                                                                                                              errorCode: error.code)).toMessageString() {
            contextPool.widget.sendMessage(toWidget: kBoardWidgetId,
                                           message: message)
        }
    }
    
    func handleGrantUsers(_ list: Array<String>?) {
        if let users = list,
           users.contains(contextPool.user.getLocalUserInfo().userUuid) {
            localGranted = true
        } else {
            localGranted = false
        }
    }
}

// MARK: - AgoraWidgetMessageObserver
extension AkBoardUIController: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard widgetId == kBoardWidgetId,
              let signal = message.toBoardSignal() else {
            return
        }
        
        switch signal {
        case .BoardPhaseChanged(let phase):
            handleBoardPhase(phase)
        case .BoardAudioMixingRequest(let requestData):
            handleAudioMixing(requestData)
        case .BoardGrantDataChanged(let list):
            handleGrantUsers(list)
        default:
            break
        }
    }
}

extension AkBoardUIController: AgoraWidgetActivityObserver {
    func onWidgetActive(_ widgetId: String) {
        guard widgetId == kBoardWidgetId else {
            return
        }
        
        initBoardWidget()
        joinBoard()
    }
    
    func onWidgetInactive(_ widgetId: String) {
        guard widgetId == kBoardWidgetId else {
            return
        }
        
        deinitBoardWidget()
    }
}

extension AkBoardUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        initBoardWidget()
        joinBoard()
    }
}

extension AkBoardUIController: AgoraEduMediaHandler {
    public func onAudioMixingStateChanged(stateCode: Int,
                                          errorCode: Int) {
        let data = AgoraBoardWidgetAudioMixingChangeData(stateCode: stateCode,
                                                         errorCode: errorCode)
        if let message = AgoraBoardWidgetSignal.AudioMixingStateChanged(data).toMessageString() {
            contextPool.widget.sendMessage(toWidget: kBoardWidgetId,
                                           message: message)
        }
    }
}
