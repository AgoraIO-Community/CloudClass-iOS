//
//  ViewController.swift
//  AgoraBuilder
//
//  Created by Cavan on 2022/7/19.
//

import UIKit
import AgoraInvigilatorSDK
import AgoraInvigilatorUI
import AgoraEduContext

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let config = AgoraInvigilatorLaunchConfig(userName: "111111",
                                                  userUuid: "111111",
                                                  userRole: .student,
                                                  roomName: "aaaaaa",
                                                  roomUuid: "aaaaaa",
                                                  roomType: .proctor,
                                                  appId: "aaaaaa",
                                                  token: "aaaaaa")
        AgoraInvigilatorSDK.launch(config) {
            print("success")
        } failure: { error in
            print("error")
        }
    }
}

