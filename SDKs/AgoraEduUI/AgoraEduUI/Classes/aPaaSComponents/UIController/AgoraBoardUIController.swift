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
    
    var needInit: Bool = false {
        didSet {
            if needInit {
                initBoardWidget()
                
                if needJoin {
                    joinBoard()
                }
            }
        }
    }
    
    var needJoin: Bool = false {
        didSet {
            if needInit {
                needInit = true
                return
            }
            if needJoin {
                joinBoard()
            }
        }
    }
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        contextPool = context
        view.backgroundColor = .clear
        needInit = true
        contextPool.room.registerRoomEventHandler(self)
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
            view.addSubview(boardWidget.view)
            self.boardWidget = boardWidget

            boardWidget.view.mas_makeConstraints { make in
                make?.left.right().top().bottom().equalTo()(0)
            }
            
            needInit = false
        }
    }
    
    func joinBoard() {
        // 需要先将白板视图添加到视图栈中再加入白板
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
           let message = AgoraBoardWidgetSignal.AudioMixingStateChanged(AgoraBoardWidgetAudioMixingChangeData(statusCode: 714,
                                                                                                              errorCode: error.code)).toMessageString() {
            contextPool.widget.sendMessage(toWidget: "netlessBoard",
                                           message: message)
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
        case .BoardInit:
            needInit = true
        case .BoardPhaseChanged(let phase):
            handleBoardPhase(phase)
        case .BoardAudioMixingRequest(let requestData):
            handleAudioMixing(requestData)
        case .BoardGrantDataChanged(let list):
            break
        default:
            break
        }
    }
}

extension AgoraBoardUIController: AgoraEduRoomHandler {
    func onRoomJoinedSuccess(roomInfo: AgoraEduContextRoomInfo) {
        needJoin = true
    }
}
