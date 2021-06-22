//
//  DebugView.swift
//  AgoraUIEduAppViews
//
//  Created by SRS on 2021/5/31.
//

import Foundation
import AgoraEduContext

class DebugButton: UIButton {
    private var tapBlock: ((DebugButton) -> Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        translate_tap_event()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        translate_tap_event()
    }
    
    public func tap(_ block: @escaping (DebugButton) -> Void) {
        tapBlock = block
    }
    
    private func translate_tap_event() {
        addTarget(self,
                  action: #selector(do_tap_event),
                  for: .touchUpInside)
    }
    
    @objc private func do_tap_event(_ button: DebugButton) {
        if let `tapBlock` = tapBlock {
            tapBlock(self)
            isUserInteractionEnabled = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [unowned self] in
                self.isUserInteractionEnabled = true
            }
        }
    }
}


class DebugView: UIView {

    @IBOutlet weak var openCameraBtn: DebugButton!
    @IBOutlet weak var closeCameraBtn: DebugButton!
    
    @IBOutlet weak var startPreviewBtn: DebugButton!
    @IBOutlet weak var stopPreviewBtn: DebugButton!
    
    @IBOutlet weak var openMicroBtn: DebugButton!
    @IBOutlet weak var closeMicroBtn: DebugButton!
    
    @IBOutlet weak var joinRoomBtn: DebugButton!
    @IBOutlet weak var leftRoomBtn: DebugButton!
    
    @IBOutlet weak var publishVideoBtn: DebugButton!
    @IBOutlet weak var unpublishVideoBtn: DebugButton!
    
    @IBOutlet weak var publishAudioBtn: DebugButton!
    @IBOutlet weak var unpublishAudioBtn: DebugButton!
    
    @IBOutlet weak var localRenderView: UIView!
    @IBOutlet weak var logLabel: UILabel!
    
    var contextPool: AgoraEduContextPool?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.logLabel.isHidden = true
            self.initButtonTap()
            self.contextPool?.room.registerEventHandler(self)
        }
    }

    func initButtonTap() {

        openCameraBtn.tap {[unowned self] (_) in
            self.contextPool?.media.openCamera()
        }
        
        closeCameraBtn.tap {[unowned self] (_) in
            self.contextPool?.media.closeCamera()
        }
        
        startPreviewBtn.tap {[unowned self] (_) in
            self.contextPool?.media.startPreview(self.localRenderView)
        }
        
        stopPreviewBtn.tap {[unowned self] (_) in
            self.contextPool?.media.stopPreview()
        }

        openMicroBtn.tap {[unowned self] (_) in
            self.contextPool?.media.openMicrophone()
        }
        
        closeMicroBtn.tap {[unowned self] (_) in
            self.contextPool?.media.closeMicrophone()
        }
        
        joinRoomBtn.tap {[unowned self] (_) in
            self.contextPool?.room.joinClassroom()
        }
        
        leftRoomBtn.tap {[unowned self] (_) in
            self.contextPool?.room.leaveRoom()
        }
        
        publishVideoBtn.tap {[unowned self] (_) in
            self.contextPool?.media.publishStream(type: .video)
        }
        
        unpublishVideoBtn.tap {[unowned self] (_) in
            self.contextPool?.media.unpublishStream(type: .video)
        }
        
        publishAudioBtn.tap {[unowned self] (_) in
            self.contextPool?.media.publishStream(type: .audio)
        }
        
        unpublishAudioBtn.tap {[unowned self] (_) in
            self.contextPool?.media.unpublishStream(type: .audio)
        }
    }
}

extension DebugView: AgoraEduRoomHandler {
    func onJoinedClassroom() {
        self.logLabel.isHidden = false
        self.logLabel.text = "加入房间成功1"
    }
}
