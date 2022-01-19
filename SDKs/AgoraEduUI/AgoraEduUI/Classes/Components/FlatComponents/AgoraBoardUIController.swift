//
//  AgoraBoardUIController.swift
//  AgoraEduUI
//
//  Created by LYY on 2021/12/9.
//

import AgoraEduContext
import AgoraWidget

class AgoraBoardUIController: UIViewController {
    var boardWidget: AgoraBaseWidget?
    var contextPool: AgoraEduContextPool!
    
    private var localGranted = false {
        didSet {
            guard localGranted != oldValue else {
                return
            }
            if localGranted {
                AgoraToast.toast(msg: "board_granted".agedu_localized(),
                                 type: .notice)
            } else {
                AgoraToast.toast(msg: "board_ungranted".agedu_localized(),
                                 type: .error)
            }
        }
    }
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        contextPool = context
        view.backgroundColor = .clear
        
        contextPool.room.registerRoomEventHandler(self)
        contextPool.media.registerMediaEventHandler(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - private
private extension AgoraBoardUIController {
    func initBoardWidget() {
        if let boardConfig = contextPool.widget.getWidgetConfig("netlessBoard") {
            let boardWidget = contextPool.widget.create(boardConfig)
            contextPool.widget.add(self,
                                   widgetId: boardConfig.widgetId)
            view.isUserInteractionEnabled = true
            view.addSubview(boardWidget.view)
            self.boardWidget = boardWidget

            boardWidget.view.mas_makeConstraints { make in
                make?.left.right().top().bottom().equalTo()(0)
            }
        }
    }
    
    func joinBoard() {
        if let message = AgoraBoardWidgetSignal.JoinBoard.toMessageString() {
            contextPool.widget.sendMessage(toWidget: "netlessBoard",
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
            contextPool.widget.sendMessage(toWidget: "netlessBoard",
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

extension AgoraBoardUIController: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard widgetId == "netlessBoard",
              let signal = message.toSignal() else {
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

extension AgoraBoardUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        initBoardWidget()
        joinBoard()
    }
}

extension AgoraBoardUIController: AgoraEduMediaHandler {
    public func onAudioMixingStateChanged(stateCode: Int,
                                          errorCode: Int) {
        let data = AgoraBoardWidgetAudioMixingChangeData(stateCode: stateCode,
                                                         errorCode: errorCode)
        if let message = AgoraBoardWidgetSignal.AudioMixingStateChanged(data).toMessageString() {
            contextPool.widget.sendMessage(toWidget: "netlessBoard",
                                           message: message)
        }
    }
}
