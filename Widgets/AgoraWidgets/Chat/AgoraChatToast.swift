//
//  AgoraChatToast.swift
//  AgoraWidgets
//
//  Created by Cavan on 2021/7/21.
//

import Foundation

// MARK: - Text
extension AgoraChatWidget {
    func remoteSilenced(_ remoteUser: String,
                        operatorUser: String) -> String {
        if UIDevice.current.isChineseLanguage {
            return "\(remoteUser)被\(operatorUser)禁言了"
        } else {
            return "\(remoteUser) was silenced by \(operatorUser)."
        }
    }
    
    func localSilenced(operatorUser: String) -> String {
        if UIDevice.current.isChineseLanguage {
            return "你被\(operatorUser)禁言了"
        } else {
            return "you were silenced by \(operatorUser)."
        }
    }
    
    func remoteUnsilenced(_ remoteUser: String,
                          operatorUser: String) -> String {
        if UIDevice.current.isChineseLanguage {
            return "\(remoteUser)被\(operatorUser)解除了禁言"
        } else {
            return "\(remoteUser) was allowed to chat by \(operatorUser)."
        }
    }
    
    func localUnsilenced(operatorUser: String) -> String {
        if UIDevice.current.isChineseLanguage {
            return "你被\(operatorUser)解除了禁言"
        } else {
            return "you were allowed to chat by \(operatorUser)."
        }
    }
    
    func roomSilencedChanged(hasRoomChatPermission: Bool) -> String {
        if UIDevice.current.isChineseLanguage {
            return hasRoomChatPermission ? "禁言模式关闭" : "禁言模式开启"
        } else {
            return hasRoomChatPermission ? "Turn off mute mode" :  "Turn on mute mode"
        }
    }
}
