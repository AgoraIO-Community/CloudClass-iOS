//
//  AgoraSpreadUIController.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2022/1/7.
//

import UIKit
import AgoraEduContext

protocol AgoraSpreadUIControllerDelegate: NSObjectProtocol {
    
    func renderViewForUser(with userId: String) -> UIView
    
}
class AgoraSpreadUIController: UIViewController {
    
    weak var delegate: AgoraSpreadUIControllerDelegate?
    /** SDK环境*/
    var contextPool: AgoraEduContextPool!
    
    deinit {
        print("\(#function): \(self.classForCoder)")
    }
    
    init(context: AgoraEduContextPool) {
        super.init(nibName: nil, bundle: nil)
        contextPool = context
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createWidget()
    }
}
// MARK: - Creations
private extension AgoraSpreadUIController {
    func createWidget() {
        
    }
}
