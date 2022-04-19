//
//  AgoraBoardUIController.swift
//  AgoraEduUI
//
//  Created by LYY on 2021/12/9.
//

import AgoraEduContext
import AgoraWidget

class AgoraBoardUIController: UIViewController {
    private var contextPool: AgoraEduContextPool!
    private var subRoom: AgoraEduSubRoomContext?
    private var boardWidget: AgoraBaseWidget?
    
    private var widgetController: AgoraEduWidgetContext {
        if let `subRoom` = subRoom {
            return subRoom.widget
        } else {
            return contextPool.widget
        }
    }
    private var grantUsers = [String]() {
        didSet {
            if grantUsers.contains(contextPool.user.getLocalUserInfo().userUuid) {
                localGranted = true
            } else {
                localGranted = false
            }
        }
    }
    
    private var localGranted = false {
        didSet {
            guard localGranted != oldValue,
                  contextPool.user.getLocalUserInfo().userRole != .teacher else {
                return
            }
            if !localGranted {
                AgoraToast.toast(msg: "fcr_netless_board_ungranted".agedu_localized(),
                                 type: .error)
            } else {
                AgoraToast.toast(msg: "fcr_netless_board_granted".agedu_localized(),
                                 type: .notice)
            }
        }
    } 
    
    init(context: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext? = nil) {
        super.init(nibName: nil,
                   bundle: nil)
        self.contextPool = context
        self.subRoom = subRoom
        view.backgroundColor = .white
        
        if let `subRoom` = subRoom {
            subRoom.registerSubRoomEventHandler(self)
        } else {
            contextPool.room.registerRoomEventHandler(self)
        }
        
        contextPool.media.registerMediaEventHandler(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        UIApplication.shared.windows[0].endEditing(true)
    }
    
    func viewWillActive() {
        guard widgetController.getWidgetActivity(kBoardWidgetId) else {
            return
        }
        
        widgetController.add(self)
        
        initBoardWidget()
        joinBoard()
    }
    
    func viewWillInactive() {
        widgetController.remove(self)
        
        deinitBoardWidget()
    }
}

// MARK: - private
private extension AgoraBoardUIController {
    func initBoardWidget() {
        guard let boardConfig = widgetController.getWidgetConfig(kBoardWidgetId),
              self.boardWidget == nil else {
            return
        }
        
        let widget = widgetController.create(boardConfig)
        widgetController.add(self,
                             widgetId: boardConfig.widgetId)
        
        let group = AgoraUIGroup()
        widget.view.backgroundColor = group.color.board_bg_color
        widget.view.layer.borderColor = group.color.board_border_color
        widget.view.layer.borderWidth = group.frame.board_border_width
        widget.view.layer.cornerRadius = group.frame.board_corner_radius
        widget.view.layer.masksToBounds = true
        
        view.addSubview(widget.view)
        boardWidget = widget

        widget.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        
//        self.view.layoutIfNeeded()
    }
    
    func deinitBoardWidget() {
        boardWidget?.view.removeFromSuperview()
        boardWidget = nil
        widgetController.remove(self,
                                widgetId: kBoardWidgetId)
    }
    
    func joinBoard() {
        if let message = AgoraBoardWidgetSignal.JoinBoard.toMessageString() {
            widgetController.sendMessage(toWidget: kBoardWidgetId,
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
            widgetController.sendMessage(toWidget: kBoardWidgetId,
                                         message: message)
        }
    }
    
    func handleGrantUsers(_ list: Array<String>) {
        grantUsers = list
    }
}

// MARK: - AgoraWidgetMessageObserver
extension AgoraBoardUIController: AgoraWidgetMessageObserver {
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
        case .GetBoardGrantedUsers(let list):
            handleGrantUsers(list)
        default:
            break
        }
    }
}

extension AgoraBoardUIController: AgoraWidgetActivityObserver {
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

// MARK: - AgoraEduRoomHandler
extension AgoraBoardUIController: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        viewWillActive()
    }
}

// MARK: - AgoraEduSubRoomHandler
extension AgoraBoardUIController: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        viewWillActive()
        let localUserInfo = contextPool.user.getLocalUserInfo()
        
        guard !localGranted,
              localUserInfo.userRole != .teacher else {
            return
        }
        let type = AgoraBoardWidgetSignal.UpdateGrantedUsers(.add([localUserInfo.userUuid]))

        if let message = type.toMessageString() {
            widgetController.sendMessage(toWidget: kBoardWidgetId,
                                         message: message)
        }
    }
    
    func onSubRoomClosed() {
        deinitBoardWidget()
    }
}

// MARK: - AgoraEduMediaHandler
extension AgoraBoardUIController: AgoraEduMediaHandler {
    public func onAudioMixingStateChanged(stateCode: Int,
                                          errorCode: Int) {
        let data = AgoraBoardWidgetAudioMixingChangeData(stateCode: stateCode,
                                                         errorCode: errorCode)
        if let message = AgoraBoardWidgetSignal.AudioMixingStateChanged(data).toMessageString() {
            widgetController.sendMessage(toWidget: kBoardWidgetId,
                                         message: message)
        }
    }
}
