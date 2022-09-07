//
//  ViewController.swift
//  AgoraBuilder
//
//  Created by Cavan on 2022/7/19.
//

import UIKit
import AgoraInvigilatorSDK

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        view.isUserInteractionEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        let userName = "010101"
        let roomName = "010101"
        let userId = "\(userName.md5())2"
        let roomId = "\(roomName.md5())6"
        
        let config = AgoraInvigilatorLaunchConfig(userName: userName,
                                                  userUuid: userId,
                                                  userRole: .student,
                                                  roomName: "aaaaaa",
                                                  roomUuid: "aaaaaa",
                                                  roomType: .proctor,
                                                  appId: "aaaaaa",
                                                  token: "aaaaaa")
        AgoraInvigilatorSDK.launch(config) {
            
        } failure: { error in
            
        }
    }
}

extension Bundle {
    var version: String {
        guard let infoDictionary = Bundle.main.infoDictionary,
              let version = infoDictionary["CFBundleShortVersionString"] as? String else {
            return ""
        }
        return version
    }
}

extension String {
    func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deallocate()
        return hash as String
    }
}
