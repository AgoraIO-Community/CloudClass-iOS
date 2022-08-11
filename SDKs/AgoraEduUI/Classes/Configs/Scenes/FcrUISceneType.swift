//
//  FcrUIScene.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/8/3.
//

import Foundation

@objc public enum FcrUISceneType: Int {
    case oneToOne, small, lecture, vocation
}

extension FcrUISceneType {
    public static func getList() -> [FcrUISceneType] {
        return [.oneToOne,
                .small,
                .lecture,
                .vocation]
    }
}
