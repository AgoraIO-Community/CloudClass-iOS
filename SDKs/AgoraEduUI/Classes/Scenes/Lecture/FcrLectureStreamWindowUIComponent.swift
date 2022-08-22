//
//  FcrLectureStreamWindowUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/6/17.
//

import AgoraEduContext
import AgoraUIBaseViews
import AgoraWidget
import UIKit

protocol FcrLectureStreamWindowUIComponentDelegate: NSObjectProtocol {
    func onStreamWindow(_ component: FcrLectureStreamWindowUIComponent,
                        didPressUser uuid: String,
                        view: UIView)
}

class FcrLectureStreamWindowUIComponent: FcrStreamWindowUIComponent {
    
    public var actionDelegate: FcrLectureStreamWindowUIComponentDelegate?
    
    init(roomController: AgoraEduRoomContext,
         userController: AgoraEduUserContext,
         streamController: AgoraEduStreamContext,
         mediaController: AgoraEduMediaContext,
         widgetController: AgoraEduWidgetContext,
         subRoom: AgoraEduSubRoomContext? = nil,
         delegate: FcrStreamWindowUIComponentDelegate? = nil,
         componentDataSource: FcrUIComponentDataSource? = nil,
         actionDelegate: FcrLectureStreamWindowUIComponentDelegate? = nil) {
        super.init(roomController: roomController,
                   userController: userController,
                   streamController: streamController,
                   mediaController: mediaController,
                   widgetController: widgetController,
                   subRoom: subRoom,
                   delegate: delegate,
                   componentDataSource: componentDataSource)
        self.actionDelegate = actionDelegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func onStreamUpdated(stream: AgoraEduContextStreamInfo,
                                  operatorUser: AgoraEduContextUserInfo?) {
        super.onStreamUpdated(stream: stream,
                              operatorUser: operatorUser)
        guard stream.hasAudio else {
            return
        }
        
        mediaController.startPlayAudio(roomUuid: roomId,
                                       streamUuid: stream.streamUuid)
    }
    
    func onStreamJoined(stream: AgoraEduContextStreamInfo,
                        operatorUser: AgoraEduContextUserInfo?) {
        if stream.hasAudio {
            mediaController.startPlayAudio(roomUuid: roomId,
                                           streamUuid: stream.streamUuid)
        } else {
            mediaController.stopPlayAudio(roomUuid: roomId,
                                          streamUuid: stream.streamUuid)
        }
        guard userController.getLocalUserInfo().userRole == .teacher ||
                userController.getLocalUserInfo().userRole == .assistant,
              stream.owner.userRole == .student
        else {
            // 本地用户是老师或者助教，需要同步widget
            return
        }
        createWidgetWith(stream: stream)
    }
    
    func onStreamLeft(stream: AgoraEduContextStreamInfo,
                      operatorUser: AgoraEduContextUserInfo?) {
        mediaController.stopPlayAudio(roomUuid: roomId,
                                      streamUuid: stream.streamUuid)
    }
    
    override func onAddedRenderWidget(widgetView: UIView) {
        super.onAddedRenderWidget(widgetView: widgetView)
        guard userController.getLocalUserInfo().userRole == .teacher ||
                userController.getLocalUserInfo().userRole == .assistant
        else {
            // 本地用户是老师或者助教，可以操作widget
            return
        }
        let drag = UIPanGestureRecognizer(target: self,
                                          action:#selector(onDrage(_:)))
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(onTap(_:)))
        tap.delegate = self
        tap.numberOfTouchesRequired = 1
        let doubleTap = UITapGestureRecognizer(target: self,
                                               action: #selector(onDoubleTap(_:)))
        doubleTap.delegate = self
        doubleTap.numberOfTouchesRequired = 2
        tap.require(toFail: doubleTap)
        widgetView.addGestureRecognizers([drag, tap, doubleTap])
    }
    
}
// MARK: - Teacher Create Widget
private extension FcrLectureStreamWindowUIComponent {
    
    func createWidgetWith(stream: AgoraEduContextStreamInfo) {
        guard let config = widgetController.getWidgetConfig(WindowWidgetId) else {
            return
        }
        let streamId = stream.streamUuid
        let widgetId = "\(WindowWidgetId)-\(streamId)"
        config.widgetId = widgetId
        let _ = widgetController.create(config)
        widgetController.setWidgetActive(widgetId,
                                         ownerUuid: stream.owner.userUuid,
                                         roomProperties: nil,
                                         syncFrame: widgetInitialPosition(),
                                         success: nil,
                                         failure: nil)
    }
    
    func widgetInitialPosition() ->  AgoraWidgetFrame {
        let count = CGFloat(dataSource.count)
        let x = (count + 1) * AgoraFit.scale(5)
        let y = (count + 1) * AgoraFit.scale(5)
        let width = AgoraFit.scale(115)
        let height = AgoraFit.scale(95)
        let rect = CGRect(x: x,
                          y: y,
                          width: width,
                          height: height)
        return rect.syncFrameInView(view)
    }
    
    @objc func onDrage(_ sender: UIPanGestureRecognizer) {
        guard let targetView = sender.view as? AgoraBaseUIContainer else {
            return
        }
        let size = sender.translation(in: view)
        
        let viewWidth = targetView.width
        let viewHeight = targetView.height
        
        switch sender.state {
        case .changed:
            var nextX = targetView.frame.minX + size.x
            nextX = (nextX >= 0) ? nextX : 0
            nextX = (nextX + viewWidth <= view.width) ? nextX : (view.width - viewWidth)
            
            var nextY = targetView.frame.minY + size.y
            nextY = (nextY >= 0) ? nextY : 0
            nextY = (nextY + viewHeight <= view.height) ? nextY : (view.height - viewHeight)
            
            var frame = targetView.frame
            frame.origin.x = nextX
            frame.origin.y = nextY
            targetView.frame = frame
        case .recognized: fallthrough
        case .ended:
            guard let widgetView = sender.view,
                  let item = dataSource.first(where: {$0.widget?.view == widgetView})
            else {
                return
            }
            widgetController.updateWidgetSyncFrame(targetView.frame.syncFrameInView(view),
                                                   widgetId: item.widgetId,
                                                   success: nil)
            break
        default:
            break
        }
        sender.setTranslation(.zero,
                              in: view)
    }
    
    @objc func onTap(_ sender: UITapGestureRecognizer) {
        guard let widgetView = sender.view,
              let item = dataSource.first(where: {$0.widget?.view == widgetView})
        else {
            return
        }
        actionDelegate?.onStreamWindow(self,
                                       didPressUser: item.data.userId,
                                       view: widgetView)
    }
    
    @objc func onDoubleTap(_ sender: UITapGestureRecognizer) {
        
    }
}

extension FcrLectureStreamWindowUIComponent: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldReceive event: UIEvent) -> Bool {
        guard let view = gestureRecognizer.view as? AgoraBaseUIContainer else {
            return false
        }
        
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
