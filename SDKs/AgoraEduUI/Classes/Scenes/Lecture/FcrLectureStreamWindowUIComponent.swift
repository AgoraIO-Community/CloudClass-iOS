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

class FcrLectureStreamWindowUIComponent: FcrStreamWindowUIComponent {
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
        guard contextPool.user.getLocalUserInfo().userRole == .teacher ||
                contextPool.user.getLocalUserInfo().userRole == .assistant,
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
        guard contextPool.user.getLocalUserInfo().userRole == .teacher ||
                contextPool.user.getLocalUserInfo().userRole == .assistant
        else {
            // 本地用户是老师或者助教，可以操作widget
            return
        }
        let drag = UIPanGestureRecognizer(target: self,
                                          action:#selector(onDrage(_:)))
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(onTap(_:)))
        tap.delegate = self
        widgetView.addGestureRecognizers([drag, tap])
    }
    
}
// MARK: - Teacher Create Widget
private extension FcrLectureStreamWindowUIComponent {
    
    func createWidgetWith(stream: AgoraEduContextStreamInfo) {
        guard let config = contextPool.widget.getWidgetConfig(WindowWidgetId) else {
            return
        }
        let streamId = stream.streamUuid
        let windowId = "\(WindowWidgetId)-\(streamId)"
        config.widgetId = windowId
        let widget = contextPool.widget.create(config)
        contextPool.widget.updateWidgetSyncFrame(widgetInitialPosition(),
                                                 widgetId: windowId) { [weak self] in
            self?.contextPool.widget.setWidgetActive(windowId,
                                                     ownerUuid: stream.owner.userUuid,
                                                     roomProperties: nil,
                                                     success: nil)
        } failure: { erro in
        }
    }
    
    func widgetInitialPosition() ->  AgoraWidgetFrame {
        let count = CGFloat(widgets.count)
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

        let point = sender.translation(in: view)
        
        let viewWidth = targetView.width
        let viewHeight = targetView.height
        
        let transLeft = targetView.frame.minX + point.x
        let transTop = targetView.frame.minY + point.y
        
        switch sender.state {
        case .changed:
            break
        case .recognized: fallthrough
        case .ended:
            
            break
        default:
            break
        }
        sender.setTranslation(.zero,
                              in: view)
    }
    
    @objc func onTap(_ sender: UITapGestureRecognizer) {
        
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
