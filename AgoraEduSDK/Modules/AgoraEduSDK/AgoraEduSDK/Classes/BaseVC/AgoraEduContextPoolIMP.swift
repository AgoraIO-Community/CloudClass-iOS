//1
//  AgoraEduContextImp.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/4/16.
//  Copyright © 2021 Agora. All rights reserved.
//

import AgoraEduContext
import AgoraUIEduAppViews

@objcMembers public class AgoraEduContextPoolIMP: NSObject {
    private lazy var tmp: AgoraEduContextPoolTmp = {
        return AgoraEduContextPoolTmp(self)
    }()
    
    public weak var whiteBoardIMP: AgoraEduWhiteBoardContext?
    public weak var whiteBoardToolIMP: AgoraEduWhiteBoardToolContext?
    public weak var whiteBoardPageControlIMP: AgoraEduWhiteBoardPageControlContext?
    public weak var roomIMP: AgoraEduRoomContext?
    public weak var deviceIMP: AgoraEduDeviceContext?
    public weak var mediaIMP: AgoraEduMediaContext?
    public weak var chatIMP: AgoraEduMessageContext?
    public weak var userIMP: AgoraEduUserContext?
    public weak var handsUpIMP: AgoraEduHandsUpContext?
    public weak var privateChatIMP: AgoraEduPrivateChatContext?
    public weak var shareScreenIMP: AgoraEduScreenShareContext?
    public weak var extAppIMP: AgoraEduExtAppContext?
    public weak var widgetIMP: AgoraEduWidgetContext?

    public override init() {
        super.init()
    }
    
    public func eduContextPool() -> AgoraEduContextPool {
        return self.tmp
    }
}

extension AgoraEduContextPoolIMP {
    public func agoraUIManager(_ viewType: AgoraEduContextAppType) -> AgoraUIManager {
        return AgoraUIManager(viewType: viewType,
                              contextPool: self.tmp)
    }
}

// MARK: - AgoraEduContextPoolTmp
@objcMembers public class AgoraEduContextPoolTmp: NSObject, AgoraEduContextPool {
    
    private weak var imp: AgoraEduContextPoolIMP?
    
    init(_ imp: AgoraEduContextPoolIMP) {
        self.imp = imp
    }
    
    public var extApp: AgoraEduExtAppContext {
        get {
            let extAppIMP = self.imp?.extAppIMP
            assert(extAppIMP != nil, "must init contextPool.extAppIMP")
            return extAppIMP!
        }
    }
    
    public var whiteBoard: AgoraEduWhiteBoardContext {
        get {
            let whiteBoardIMP = self.imp?.whiteBoardIMP
            assert(whiteBoardIMP != nil, "must init contextPool.whiteBoardIMP")
            return whiteBoardIMP!
        }
    }
    
    public var whiteBoardTool: AgoraEduWhiteBoardToolContext {
        get {
            let whiteBoardToolIMP = self.imp?.whiteBoardToolIMP
            assert(whiteBoardToolIMP != nil, "must init contextPool.whiteBoardToolIMP")
            return whiteBoardToolIMP!
        }
    }
    
    public var whiteBoardPageControl: AgoraEduWhiteBoardPageControlContext {
        get {
            let whiteBoardPageControlIMP = self.imp?.whiteBoardPageControlIMP
            assert(whiteBoardPageControlIMP != nil, "must init contextPool.whiteBoardPageControlIMP")
            return whiteBoardPageControlIMP!
        }
    }
    
    public var room: AgoraEduRoomContext {
        get {
            let roomIMP = self.imp?.roomIMP
            assert(roomIMP != nil, "must init contextPool.roomIMP")
            return roomIMP!
        }
    }
    
    public var device: AgoraEduDeviceContext {
        get {
            let deviceIMP = self.imp?.deviceIMP
            assert(deviceIMP != nil, "must init contextPool.deviceIMP")
            return deviceIMP!
        }
    }
    
    public var media: AgoraEduMediaContext {
        get {
            let mediaIMP = self.imp?.mediaIMP
            assert(mediaIMP != nil, "must init contextPool.mediaIMP")
            return mediaIMP!
        }
    }
    
    public var chat: AgoraEduMessageContext {
        get {
            let chatIMP = self.imp?.chatIMP
            assert(chatIMP != nil, "must init contextPool.chatIMP")
            return chatIMP!
        }
    }
    
    public var user: AgoraEduUserContext {
        get {
            let userIMP = self.imp?.userIMP
            assert(userIMP != nil, "must init contextPool.userIMP")
            return userIMP!
        }
    }
    
    public var handsUp: AgoraEduHandsUpContext {
        get {
            let handsUpIMP = self.imp?.handsUpIMP
            assert(handsUpIMP != nil, "must init contextPool.handsUpIMP")
            return handsUpIMP!
        }
    }
    
    public var privateChat: AgoraEduPrivateChatContext {
        get {
            let privateChatIMP = self.imp?.privateChatIMP
            assert(privateChatIMP != nil, "must init contextPool.privateChatIMP")
            return privateChatIMP!
        }
    }
    
    public var shareScreen: AgoraEduScreenShareContext {
        get {
            let shareScreenIMP = self.imp?.shareScreenIMP
            assert(shareScreenIMP != nil, "must init contextPool.shareScreenIMP")
            return shareScreenIMP!
        }
    }
    
    public var widget: AgoraEduWidgetContext {
        get {
            let widgetIMP = self.imp?.widgetIMP
            assert(widgetIMP != nil, "must init contextPool.widgetIMP")
            return widgetIMP!
        }
    }
}
