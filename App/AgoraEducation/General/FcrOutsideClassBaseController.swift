//
//  FcrOutsideClassBaseViewController.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/7/22.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit

class FcrOutsideClassBaseController: UIViewController {
    
    public override var shouldAutorotate: Bool {
        return true
    }
    
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return LoginConfig.device == .iPad ? .landscapeRight : .portrait
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return LoginConfig.device == .iPad ? .landscapeRight : .portrait
    }
}
