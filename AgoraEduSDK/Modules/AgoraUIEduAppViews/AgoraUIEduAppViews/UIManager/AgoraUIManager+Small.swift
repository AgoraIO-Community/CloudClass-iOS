//
//  AgoraUIManager+Small.swift
//  AgoraUIEduAppViews
//
//  Created by SRS on 2021/4/16.
//

import Foundation
import AgoraUIBaseViews
import AgoraUIEduBaseViews

fileprivate let MENU_TAG = 100

extension AgoraUIManager {
    func addSmallContainerViews() {
        guard let `room` = self.room,
              let `whiteBoard` = self.whiteBoard,
              let `shareScreen` = self.shareScreen,
              let `renderSmall` = self.renderSmall,
              let `userList` = self.userList,
              let `set` = self.set else  {
            return
        }
        
        appContainerView.addSubview(room.containerView)
        appContainerView.addSubview(renderSmall.containerView)
        appContainerView.addSubview(whiteBoard.containerView)
        appContainerView.addSubview(shareScreen.containerView)
        
        self.initMenuView()
        appContainerView.addSubview(self.menuView)
        self.menuView.agora_right = 0
        self.menuView.agora_bottom = 0

        appContainerView.addSubview(userList.containerView)
        appContainerView.addSubview(set.containerView)

        set.containerView.isHidden = true
        whiteBoard.boardPageControl.isHidden = true
    }

    func layoutSmallContainerViews() {
        guard let `room` = self.room,
              let `whiteBoard` = self.whiteBoard,
              let `shareScreen` = self.shareScreen,
              let `renderSmall` = self.renderSmall,
              let `handsUp` = self.handsUp,
              let `userList` = self.userList,
              let `set` = self.set else  {
            return
        }
        
        let isPad = AgoraKitDeviceAssistant.OS.isPad
        
        room.containerView.agora_x = 0
        room.containerView.agora_right = 0
        room.containerView.agora_height = AgoraNavBarHeight
        room.containerView.agora_y = 0
        
        let top = AgoraNavBarHeight + AgoraVideoGapY
        
        let size = renderSmall.renderViewSize
        renderSmall.containerView.agora_x = 0
        renderSmall.containerView.agora_y = top
        renderSmall.containerView.agora_right = 0
        renderSmall.containerView.agora_height = size.height

        whiteBoard.containerView.agora_x = 0
        whiteBoard.containerView.agora_height = AgoraBoardHeight
        whiteBoard.containerView.agora_bottom = 0
        whiteBoard.containerView.agora_right = 0
        
        shareScreen.containerView.agora_x = 0
        shareScreen.containerView.agora_height = AgoraBoardHeight
        shareScreen.containerView.agora_bottom = 0
        shareScreen.containerView.agora_right = 0
        
        userList.containerView.agora_width = 548
        userList.containerView.agora_height = 312
        userList.containerView.agora_safe_bottom = 15
        userList.containerView.agora_right = isPad ? 60 : 50
        
        set.containerView.agora_width = 280
        set.containerView.agora_height = 256
        set.containerView.agora_safe_bottom = 15
        set.containerView.agora_right = isPad ? 60 : 50
    }
    
    // TODO: 后面需要把menu都抽取一个单独的Controller
    func initMenuView() {
        
        guard let `handsUp` = self.handsUp else  {
            return
        }

        // menu
        let isPad = AgoraKitDeviceAssistant.OS.isPad
        let MenuSize = CGSize(width: isPad ? 54 : 42,
                              height: isPad ? 54 : 42)
        let MenuRight: CGFloat = 4
        let MenuGap: CGFloat = 0
        let MenuBottom: CGFloat = 7
        // handsUp比较特殊， 宽高由子view填充
        handsUp.containerView.tag = 1 + MENU_TAG
        handsUp.containerView.isUserInteractionEnabled = false

        menuView.addSubview(handsUp.containerView)
        handsUp.containerView.agora_safe_bottom = MenuBottom
        handsUp.containerView.agora_right = MenuRight
        handsUp.updateMenu(width: MenuSize.width,
                           height: MenuSize.height)
        
        // ChatMenu
        let chatMenu = AgoraBaseUIButton()
        chatMenu.setBackgroundImage(AgoraKitImage("menu_chat_0"),
                                    for: .normal)
        chatMenu.setBackgroundImage(AgoraKitImage("menu_chat_1"),
                                    for: .selected)
        chatMenu.setBackgroundImage(AgoraKitImage("menu_chat_1"),
                                    for: .highlighted)
        chatMenu.addTarget(self,
                           action: #selector(onChatPressed(_:)),
                           for: .touchUpInside)
        chatMenu.tag = 2 + MENU_TAG
        chatMenu.isUserInteractionEnabled = false
        menuView.insertSubview(chatMenu, at: 0)
        chatMenu.agora_width = MenuSize.width
        chatMenu.agora_height = MenuSize.height
        chatMenu.agora_safe_bottom = MenuBottom + 1 * (MenuSize.height + MenuGap)
        chatMenu.agora_right = MenuRight
        
        // ChatRed
        let chatBadgeView = AgoraBaseUIView()
        chatBadgeView.backgroundColor = .red
        chatBadgeView.tag = 1
        chatBadgeView.isHidden = true
        chatMenu.addSubview(chatBadgeView)
        chatBadgeView.agora_width = chatMenu.agora_width * 0.2
        chatBadgeView.agora_height = chatBadgeView.agora_width
        chatBadgeView.agora_y = isPad ? 8 : 5
        chatBadgeView.agora_right = isPad ? 8 : 5
        chatBadgeView.layer.cornerRadius = chatBadgeView.agora_height * 0.5;
        
        // UserListMenu
        let userListMenu = AgoraBaseUIButton()
        userListMenu.setBackgroundImage(AgoraKitImage("menu_userlist_0"),
                                        for: .normal)
        userListMenu.setBackgroundImage(AgoraKitImage("menu_userlist_1"),
                                        for: .selected)
        userListMenu.setBackgroundImage(AgoraKitImage("menu_userlist_1"),
                                        for: .highlighted)
        userListMenu.addTarget(self,
                               action: #selector(onUserListPressed(_:)),
                               for: .touchUpInside)
        userListMenu.tag = 3 + MENU_TAG
        menuView.insertSubview(userListMenu, at: 0)
        userListMenu.agora_width = MenuSize.width
        userListMenu.agora_height = MenuSize.height
        userListMenu.agora_safe_bottom = MenuBottom + 2 * (MenuSize.height + MenuGap)
        userListMenu.agora_right = MenuRight
        
        // LogMenu
        let logMenu = AgoraBaseUIButton()
        logMenu.setBackgroundImage(AgoraKitImage("menu_log_0"),
                                   for: .normal)
        logMenu.setBackgroundImage(AgoraKitImage("menu_log_1"),
                                   for: .highlighted)
        logMenu.addTarget(self,
                          action: #selector(onLogPressed(_:)),
                          for: .touchUpInside)
        logMenu.tag = 4 + MENU_TAG
        menuView.insertSubview(logMenu, at: 0)
        logMenu.agora_width = MenuSize.width
        logMenu.agora_height = MenuSize.height
        logMenu.agora_safe_bottom = MenuBottom + 3 * (MenuSize.height + MenuGap)
        logMenu.agora_right = MenuRight
        
        // SetMenu
        let setMenu = AgoraBaseUIButton()
        setMenu.setBackgroundImage(AgoraKitImage("menu_set_0"),
                                   for: .normal)
        setMenu.setBackgroundImage(AgoraKitImage("menu_set_1"),
                                   for: .selected)
        setMenu.setBackgroundImage(AgoraKitImage("menu_set_1"),
                                   for: .highlighted)
        setMenu.addTarget(self,
                          action: #selector(onSetPressed(_:)),
                          for: .touchUpInside)
        setMenu.tag = 5 + MENU_TAG
        menuView.insertSubview(setMenu, at: 0)
        setMenu.agora_width = MenuSize.width
        setMenu.agora_height = MenuSize.height
        setMenu.agora_safe_bottom = MenuBottom + 4 * (MenuSize.height + MenuGap)
        setMenu.agora_right = MenuRight
        
        // Container Fill
        setMenu.agora_x = 0
        setMenu.agora_y = 0
    }
    // 举手和聊天按钮 需要 加入成功后才可以点击
    func roomJoined() {
        self.menuView.viewWithTag(1 + MENU_TAG)?.isUserInteractionEnabled = true
        self.menuView.viewWithTag(2 + MENU_TAG)?.isUserInteractionEnabled = true
    }
    
    func showBadge(_ hidden: Bool) {
        if let redView = menuView.viewWithTag(2 + MENU_TAG)?.viewWithTag(1) {
            redView.isHidden = hidden
        }
    }
    
    func onChatPressed() {
        let btn = menuView.viewWithTag(2 + MENU_TAG) as! AgoraBaseUIButton
        onChatPressed(btn)
    }
    func onChatPressed(_ sender: AgoraBaseUIButton) {
        let isSelected = sender.isSelected
        onMenuPressed()
        sender.isSelected = !isSelected
        if sender.isSelected {
            self.hxChat?.containerView.isHidden = false
            if(self.hxChat != nil && self.hxChat!.responds(to: "showView")) {
                self.hxChat!.performSelector(onMainThread: "showView", with: nil, waitUntilDone: true)
            }
        }
    }
    
    func onUserListPressed() {
        let btn = menuView.viewWithTag(3 + MENU_TAG) as! AgoraBaseUIButton
        onUserListPressed(btn)
    }
    func onUserListPressed(_ sender: AgoraBaseUIButton) {
        let isSelected = sender.isSelected
        onMenuPressed()
        sender.isSelected = !isSelected
        if sender.isSelected {
            self.userList?.containerView.isHidden = false
        }
    }
    func onLogPressed(_ sender: AgoraBaseUIButton) {
        onMenuPressed()
        room?.uploadLog()
    }
    
    func onSetPressed() {
        let btn = menuView.viewWithTag(5 + MENU_TAG) as! AgoraBaseUIButton
        onSetPressed(btn)
    }
    func onSetPressed(_ sender: AgoraBaseUIButton) {
        let isSelected = sender.isSelected
        onMenuPressed()
        sender.isSelected = !isSelected
        if sender.isSelected {
            self.set?.containerView.isHidden = false
        }
    }
    
    // 重置menu状态
    func onMenuPressed() {
        for btn in self.menuView.subviews where btn is AgoraBaseUIButton {
            (btn as? AgoraBaseUIButton)?.isSelected = false
        }

        self.hxChat?.containerView.isHidden = true
        self.userList?.containerView.isHidden = true
        self.set?.containerView.isHidden = true
    }
}
