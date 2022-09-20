//
//  ViewController.swift
//  AgoraBuilder
//
//  Created by Cavan on 2022/7/19.
//

import UIKit
import AgoraProctorSDK

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        view.isUserInteractionEnabled = true
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
