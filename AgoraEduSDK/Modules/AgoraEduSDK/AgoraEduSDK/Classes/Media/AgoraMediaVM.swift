//
//  AgoraMediaVM.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/6/2.
//

import EduSDK
import AgoraEduContext

@objcMembers public class AgoraMediaVM: AgoraBaseVM {
    // 开启摄像头
    public func openCamera() {
        let mediaControl = AgoraEduManager.share().eduManager.getAgoraMediaControl()
        let cameraVideoTrack = mediaControl.createCameraVideoTrack()
        cameraVideoTrack.start()
    }
    // 关闭摄像头
    public func closeCamera() {
        let mediaControl = AgoraEduManager.share().eduManager.getAgoraMediaControl()
        let cameraVideoTrack = mediaControl.createCameraVideoTrack()
        cameraVideoTrack.stop()
    }
    public func startPreview(_ view: UIView) {
        let mediaControl = AgoraEduManager.share().eduManager.getAgoraMediaControl()
        let cameraVideoTrack = mediaControl.createCameraVideoTrack()
        cameraVideoTrack.setView(view)
    }
    public func stopPreview() {
        let mediaControl = AgoraEduManager.share().eduManager.getAgoraMediaControl()
        let cameraVideoTrack = mediaControl.createCameraVideoTrack()
        cameraVideoTrack.setView(nil)
    }
    
    public func openMicrophone() {
        let mediaControl = AgoraEduManager.share().eduManager.getAgoraMediaControl()
        let microTrack = mediaControl.createMicphoneAudioTrack()
        microTrack.start()
    }
    public func closeMicrophone() {
        let mediaControl = AgoraEduManager.share().eduManager.getAgoraMediaControl()
        let microTrack = mediaControl.createMicphoneAudioTrack()
        microTrack.stop()
    }
    
    // 开始推流
    public func publishStream(type: EduContextMediaStreamType) {
        self.updateStreamState(type: type, isPublish: true)
    }
    
    // 开始推流
    public func unpublishStream(type: EduContextMediaStreamType) {
        self.updateStreamState(type: type, isPublish: false)
    }
    
    // 渲染或者关闭渲染流，view为nil代表关闭流渲染
    public func renderRemoteView(_ view: UIView?, streamUuid: String) {
        
        let subscribeBlock = { (stream: AgoraRTEStream) in
            let options = AgoraRTESubscribeOptions()
            options.subscribeAudio = stream.hasAudio
            options.subscribeVideo = view == nil ? false : true
            AgoraEduManager.share().studentService?.subscribeStream(stream, options: options, success: {
                
            }, failure: { (error) in
                
            })
        }
        
        let renderBlock = { (stream: AgoraRTEStream) in
            let config = AgoraRTERenderConfig()
            config.renderMode = .hidden
            if stream.sourceType == .screen {
                config.renderMode = .fit
            }
            
            AgoraEduManager.share().studentService?.setStreamView(view,
                                                                  stream: stream,
                                                                  renderConfig: config)
        }
        
        AgoraEduManager.share().roomManager?.getFullStreamList(success: { (streamInfos) in
            
            if let stream = streamInfos.first(where: { (streamInfo) -> Bool in
                streamInfo.streamUuid == streamUuid
            }) {
                
                subscribeBlock(stream)
                renderBlock(stream)
            }
            
        }, failure: {(error) in
           
        })
    }
}

// MARK: Private
extension AgoraMediaVM {
    private func updateStreamState(type: EduContextMediaStreamType, isPublish: Bool) {
        
        AgoraEduManager.share().roomManager?.getLocalUser(success: { (localUser) in

            var hasVideo = false
            var hasAudio = false
            if let stream = localUser.streams.first {
                hasVideo = stream.hasVideo
                hasAudio = stream.hasAudio
            }
            
            if type == .audio || type == .all {
                hasAudio = isPublish
            }
            if type == .video || type == .all {
                hasVideo = isPublish
            }
           
            let stream = AgoraRTEStream(streamUuid: localUser.streamUuid,
                                        streamName: "",
                                        sourceType: .camera,
                                        hasVideo: hasVideo,
                                        hasAudio: hasAudio,
                                        user: localUser)

            AgoraEduManager.share().studentService?.publishStream(stream, success: {

            }, failure: { (error) in

            })
        }, failure: { (error) in

        })
    }
}
