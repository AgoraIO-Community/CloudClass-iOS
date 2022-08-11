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
