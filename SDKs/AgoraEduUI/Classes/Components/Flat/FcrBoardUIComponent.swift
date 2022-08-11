//
//  AgoraBoardUIController.swift
//  AgoraEduUI
//
//  Created by LYY on 2021/12/9.
//

import AgoraEduContext
import AgoraWidget

protocol FcrBoardUIComponentDelegate: NSObjectProtocol {
    func onBoardActiveStateChanged(isActive: Bool)
    func onStageStateChanged(stageOn: Bool)
    func onBoardGrantedUserListRemoved(userList: [String])
    func onBoardGrantedUserListAdded(userList: [String])
}

extension FcrBoardUIComponentDelegate {
    func onStageStateChanged(stageOn: Bool) {
        
    }
    
    func onBoardGrantedUserListRemoved(userList: [String]) {
        
    }
    
    func onBoardGrantedUserListAdded(userList: [String]) {
        
    }
}

class FcrBoardUIComponent: UIViewController {
    private(set) var grantedUsers = [String]() {
        didSet {
            onGrantedUsersChanged(oldList: oldValue,
                                  newList: grantedUsers)
        }
    }
    
    var localGranted = false {
        didSet {
            pageControl.isHidden = !localGranted
            
            guard localGranted != oldValue else {
                return
            }
            guard contextPool.user.getLocalUserInfo().userRole != .teacher else {
                return
            }
            let msgKey = localGranted ? "fcr_netless_board_granted" : "fcr_netless_board_ungranted"
            let type: AgoraToastType = localGranted ? .notice : .error
            
            AgoraToast.toast(message: msgKey.agedu_localized(),
                             type: type)
        }
    }
    
    var widgetController: AgoraEduWidgetContext {
        if let `subRoom` = subRoom {
            return subRoom.widget
        } else {
            return contextPool.widget
        }
    }
    
    var contextPool: AgoraEduContextPool
    var subRoom: AgoraEduSubRoomContext?
    
    private var roomProperties: [String: Any]? {
        get {
            guard let subRoom = subRoom else {
                return contextPool.room.getRoomProperties()
            }
            
            return subRoom.getSubRoomProperties()
        }
    }
    private var boardWidget: AgoraBaseWidget?
    private(set) weak var delegate: FcrBoardUIComponentDelegate?
    
    /**views**/
    private lazy var pageControl = FcrBoardPageControlView(frame: .zero)
    
    /** Data */
    private var pageIndex = 1 {
        didSet {
            pageControl.updatePage(pageIndex, pages: pageCount)
        }
    }
    
    private var pageCount = 0 {
        didSet {
            pageControl.updatePage(pageIndex, pages: pageCount)
        }
    }
    
    init(context: AgoraEduContextPool,
         subRoom: AgoraEduSubRoomContext? = nil,
         delegate: FcrBoardUIComponentDelegate? = nil) {
        self.contextPool = context
        self.subRoom = subRoom
        self.delegate = delegate
        
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    func saveBoard() {
        if let message = AgoraBoardWidgetSignal.SaveBoard.toMessageString() {
            widgetController.sendMessage(toWidget: kBoardWidgetId,
                                         message: message)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
        initViewFrame()
        updateViewProperties()
        
        if let `subRoom` = subRoom {
            subRoom.registerSubRoomEventHandler(self)
        } else {
            contextPool.room.registerRoomEventHandler(self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        UIApplication.shared.windows[0].endEditing(true)
    }
    
    func onNeedChangeRatio() {
        if let message = AgoraBoardWidgetSignal.ChangeRatio.toMessageString() {
            widgetController.sendMessage(toWidget: kBoardWidgetId,
                                         message: message)
        }
    }
    
    // for subVC
    func onViewWillActive() {
        contextPool.media.registerMediaEventHandler(self)
        widgetController.add(self)
        
        guard widgetController.getWidgetActivity(kBoardWidgetId) else {
            delegate?.onBoardActiveStateChanged(isActive: false)
            return
        }
        delegate?.onBoardActiveStateChanged(isActive: true)
        
        setUp()
        joinBoardWidget()
    }
    
    func onGrantedUsersChanged(oldList: Array<String>,
                               newList: Array<String>) {
        let localUser = contextPool.user.getLocalUserInfo()
        if localUser.userRole == .teacher {
            localGranted = true
        } else {
            localGranted = newList.contains(localUser.userUuid)
        }
        
        if let insertList = oldList.insert(from: newList) {
            delegate?.onBoardGrantedUserListAdded(userList: insertList)
        }
        
        if let deletedList = oldList.delete(from: newList) {
            delegate?.onBoardGrantedUserListRemoved(userList: deletedList)
        }
    }
    
    func onViewWillInactive() {
        contextPool.media.unregisterMediaEventHandler(self)
        
        widgetController.remove(self)
        
        deinitBoardWidget()
    }
}

// MARK: - AgoraUIContentContainer
extension FcrBoardUIComponent: AgoraUIContentContainer {
    func initViews() {
        let userRole = contextPool.user.getLocalUserInfo().userRole
        guard userRole != .observer else {
            return
        }
        
        pageControl.addBtn.addTarget(self,
                                     action: #selector(onClickAddPage(_:)),
                                     for: .touchUpInside)
        pageControl.prevBtn.addTarget(self,
                                      action: #selector(onClickPrePage(_:)),
                                      for: .touchUpInside)
        pageControl.nextBtn.addTarget(self,
                                      action: #selector(onClickNextPage(_:)),
                                      for: .touchUpInside)
        
        view.addSubview(pageControl)
        pageControl.isHidden = true
        
        pageControl.agora_enable = UIConfig.netlessBoard.pageControl.enable
    }
    
    func initViewFrame() {
        let userRole = contextPool.user.getLocalUserInfo().userRole
        guard userRole != .observer else {
            return
        }
        pageControl.mas_makeConstraints { make in
            make?.left.equalTo()(view)?.offset()(UIDevice.current.agora_is_pad ? 15 : 12)
            make?.bottom.equalTo()(view)?.offset()(UIDevice.current.agora_is_pad ? -20 : -15)
            make?.height.equalTo()(UIDevice.current.agora_is_pad ? 34 : 32)
            make?.width.equalTo()(168)
        }
    }
    
    func updateViewProperties() {
        view.backgroundColor = UIConfig.netlessBoard.backgroundColor
    }
}

// MARK: - AgoraUIActivity
extension FcrBoardUIComponent: AgoraUIActivity {
    func viewWillActive() {
        onViewWillActive()
    }
    
    func viewWillInactive() {
        onViewWillInactive()
    }
}

// MARK: - private
private extension FcrBoardUIComponent {
    func joinBoardWidget() {
        guard UIConfig.netlessBoard.enable,
              let boardConfig = widgetController.getWidgetConfig(kBoardWidgetId),
              self.boardWidget == nil else {
            return
        }
        
        let widget = widgetController.create(boardConfig)
        widgetController.add(self,
                             widgetId: boardConfig.widgetId)
        
        let config = UIConfig.netlessBoard
        widget.view.layer.borderColor = config.borderColor.cgColor
        widget.view.layer.borderWidth = config.borderWidth
        
        view.addSubview(widget.view)
        view.bringSubviewToFront(pageControl)
        boardWidget = widget

        widget.view.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        
        if let message = AgoraBoardWidgetSignal.JoinBoard.toMessageString() {
            widgetController.sendMessage(toWidget: kBoardWidgetId,
                                         message: message)
        }
    }
    
    func deinitBoardWidget() {
        boardWidget?.view.removeFromSuperview()
        boardWidget = nil
        widgetController.remove(self,
                                widgetId: kBoardWidgetId)
    }
    
    func setUp() {
        guard let stageState = roomProperties?["stage"] as? Int else {
            return
        }
        
        if stageState == 1 {
            delegate?.onStageStateChanged(stageOn: true)
        } else {
            delegate?.onStageStateChanged(stageOn: false)
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
    
    func handlePhotoNoAuth(_ result: FcrBoardWidgetSnapshotResult) {
        switch result {
        case .savedToAlbum:
            AgoraToast.toast(message: "fcr_savecanvas_tips_save_successfully".agedu_localized(),
                             type: .notice)
        case .noAlbumAuth:
            let action = AgoraAlertAction(title: "fcr_savecanvas_tips_save_failed_sure".agedu_localized(), action: nil)
            AgoraAlertModel()
                .setMessage("fcr_savecanvas_tips_save_failed_tips".agedu_localized())
                .addAction(action: action)
                .show(in: self)
        case .failureToSave:
            AgoraToast.toast(message: "fcr_savecanvas_tips_save_failed".agedu_localized(),
                             type: .error)
        }
    }
    
    func movePageControl(isRight: Bool) {
        UIView.animate(withDuration: TimeInterval.agora_animation,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: { [weak self] in
            guard let `self` = self else {
                return
            }
            let move: CGFloat = UIDevice.current.agora_is_pad ? 49 : 44
            self.pageControl.transform = CGAffineTransform(translationX: isRight ? move : 0,
                                                           y: 0)
        }, completion: nil)
    }
    
    @objc func onClickAddPage(_ sender: UIButton) {
        let changeType = AgoraBoardWidgetPageChangeType.count(pageCount + 1)
        if let message = AgoraBoardWidgetSignal.BoardPageChanged(changeType).toMessageString() {
            widgetController.sendMessage(toWidget: kBoardWidgetId,
                                         message: message)
        }
    }
    
    @objc func onClickPrePage(_ sender: UIButton) {
        let changeType = AgoraBoardWidgetPageChangeType.index(pageIndex - 1 - 1)
        if let message = AgoraBoardWidgetSignal.BoardPageChanged(changeType).toMessageString() {
            widgetController.sendMessage(toWidget: kBoardWidgetId,
                                         message: message)
        }
    }
    
    @objc func onClickNextPage(_ sender: UIButton) {
        let changeType = AgoraBoardWidgetPageChangeType.index(pageIndex - 1 + 1)
        if let message = AgoraBoardWidgetSignal.BoardPageChanged(changeType).toMessageString() {
            widgetController.sendMessage(toWidget: kBoardWidgetId,
                                         message: message)
        }
    }
}

// MARK: - AgoraWidgetMessageObserver
extension FcrBoardUIComponent: AgoraWidgetMessageObserver {
    func onMessageReceived(_ message: String,
                           widgetId: String) {
        guard widgetId == kBoardWidgetId,
              let signal = message.toBoardSignal() else {
            return
        }
        
        switch signal {
        case .BoardAudioMixingRequest(let requestData):
            handleAudioMixing(requestData)
        case .GetBoardGrantedUsers(let list):
            grantedUsers = list
        case .OnBoardSaveResult(let result):
            handlePhotoNoAuth(result)
        case .BoardPageChanged(let type):
            switch type {
            case .index(let index):
                pageIndex = index + 1
            case .count(let count):
                pageCount = count
            }
        case .WindowStateChanged(let state):
            let moveRight = (state == .min)
            movePageControl(isRight: moveRight)
        default:
            break
        }
    }
}

extension FcrBoardUIComponent: AgoraWidgetActivityObserver {
    func onWidgetActive(_ widgetId: String) {
        guard widgetId == kBoardWidgetId else {
            return
        }
        delegate?.onBoardActiveStateChanged(isActive: true)
        
        joinBoardWidget()
    }
    
    func onWidgetInactive(_ widgetId: String) {
        guard widgetId == kBoardWidgetId else {
            return
        }
        pageControl.isHidden = true
        delegate?.onBoardActiveStateChanged(isActive: false)
        
        deinitBoardWidget()
    }
}

// MARK: - AgoraEduRoomHandler
extension FcrBoardUIComponent: AgoraEduRoomHandler {
    func onJoinRoomSuccess(roomInfo: AgoraEduContextRoomInfo) {
        onViewWillActive()
    }
    
    func onRoomPropertiesUpdated(changedProperties: [String : Any],
                                 cause: [String : Any]?,
                                 operatorUser: AgoraEduContextUserInfo?) {
        guard let stageState = roomProperties?["stage"] as? Int else {
            return
        }
        if stageState == 1 {
            delegate?.onStageStateChanged(stageOn: true)
        } else {
            delegate?.onStageStateChanged(stageOn: false)
        }
    }
    
    func onRoomPropertiesDeleted(keyPaths: [String],
                                 cause: [String : Any]?,
                                 operatorUser: AgoraEduContextUserInfo?) {
        
    }
}

// MARK: - AgoraEduSubRoomHandler
extension FcrBoardUIComponent: AgoraEduSubRoomHandler {
    func onJoinSubRoomSuccess(roomInfo: AgoraEduContextSubRoomInfo) {
        onViewWillActive()
        
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
extension FcrBoardUIComponent: AgoraEduMediaHandler {
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

extension Array where Element == String {
    func insert(from: [String]) -> [String]? {
        var insertArray = [String]()
    
        for item in from {
            guard !self.contains(item) else {
                continue
            }
            
            insertArray.append(item)
        }
        
        if insertArray.count == 0 {
            return nil
        } else {
            return insertArray
        }
    }
    
    func delete(from: [String]) -> [String]? {
        var deleteArray = [String]()
        
        for item in self {
            guard !from.contains(item) else {
                continue
            }
            
            deleteArray.append(item)
        }
        
        if deleteArray.count == 0 {
            return nil
        } else {
            return deleteArray
        }
    }
}
