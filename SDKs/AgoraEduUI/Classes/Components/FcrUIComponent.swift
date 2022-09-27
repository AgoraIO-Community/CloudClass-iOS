//
//  AgoraUIController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/4/26.
//

import Foundation

protocol FcrUIComponentDataSource where Self: UIViewController {
    func componentNeedGrantedUserList() -> [String]
}

class FcrUIComponent: UIViewController, FcrAlert {
    deinit {
        #if DEBUG
        print("\(#function): \(self.classForCoder)")
        #endif
    }
}
