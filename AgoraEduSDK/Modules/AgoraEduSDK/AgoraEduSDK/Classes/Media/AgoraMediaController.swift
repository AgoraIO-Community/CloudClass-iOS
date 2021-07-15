//
//  AgoraMediaController.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/6/2.
//  Copyright © 2021 Agora. All rights reserved.
//

import EduSDK
import AgoraEduContext

@objcMembers public class AgoraMediaController: NSObject, AgoraController {
    
    private var vm: AgoraMediaVM?
    public init(vmConfig: AgoraVMConfig) {
        self.vm = AgoraMediaVM(config: vmConfig)
        super.init()
    }
}
extension AgoraMediaController: AgoraEduMediaContext {
    // 开启摄像头
    public func openCamera() {
        self.vm?.openCamera()
    }
    // 关闭摄像头
    public func closeCamera() {
        self.vm?.closeCamera()
    }
    // 开启本地视频预览
    public func startPreview(_ view: UIView) {
        self.vm?.startPreview(view)
    }
    // 停止本地视频预览
    public func stopPreview() {
        self.vm?.stopPreview()
    }
    // 开启麦克风
    public func openMicrophone() {
        self.vm?.openMicrophone()
    }
    // 关闭麦克风
    public func closeMicrophone() {
        self.vm?.closeMicrophone()
    }
    // 开始推流
    public func publishStream(type: EduContextMediaStreamType){
        self.vm?.publishStream(type: type)
    }
    // 停止推流
    public func unpublishStream(type: EduContextMediaStreamType) {
        self.vm?.unpublishStream(type: type)
    }
    // 渲染或者关闭远端渲染，view为nil代表关闭渲染
    public func renderRemoteView(_ view: UIView?, streamUuid: String) {
        self.vm?.renderRemoteView(view, streamUuid: streamUuid)
    }
}

// MARK: - Life cycle
extension AgoraMediaController {
    public func viewWillAppear() {
    }
    
    public func viewDidLoad() {
    }
    
    public func viewDidAppear() {
    }
    
    public func viewWillDisappear() {
    }
    
    public func viewDidDisappear() {
    }
}
