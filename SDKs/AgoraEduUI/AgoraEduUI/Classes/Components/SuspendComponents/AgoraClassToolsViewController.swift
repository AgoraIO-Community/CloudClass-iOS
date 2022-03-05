//
//  AgoraClassToolsViewController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/3/5.
//

import AgoraEduContext
import UIKit

class AgoraClassToolsViewController: UIViewController {
    private var contextPool: AgoraEduContextPool!
    
    init(context: AgoraEduContextPool) {
        self.contextPool = context
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
