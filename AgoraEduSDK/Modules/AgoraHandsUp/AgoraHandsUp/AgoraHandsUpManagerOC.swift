//
//  HandsUpManager.swift
//  AgoraEducation
//
//  Created by SRS on 2020/11/17.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

import UIKit

@objc public protocol AgoraHandsUpManagerOCDelegate: NSObjectProtocol {
    func onHandsClicked(currentState: AgoraHandsUpOCState)
    func onHandsUpTimeOut()
}

@objc public enum AgoraHandsUpOCType : Int {
    case autoPublish        //自动发流
    case applyPublish       //申请发流
}

@objc public enum AgoraHandsUpOCState : Int {
    case none
    case handsUp
    case handsDown
    case disabled
}

public class AgoraHandsUpManagerOC: NSObject {
    
    fileprivate lazy var manager: AgoraHandsUpManager = {
        return AgoraHandsUpManager(self)
    }()
    @objc public weak var delegate: AgoraHandsUpManagerOCDelegate?
    
    @objc public func getHandsUpView() -> UIView {
        return self.manager.getHandsUpView()
    }
    
    @objc public func setHandsUpType(type: AgoraHandsUpOCType, handsUpTimeOut: Int) {
        
        var swiftType = AgoraHandsUpType.autoPublish
        if(type == .applyPublish) {
            swiftType = .applyPublish
        }
        self.manager.handsUpType = swiftType
        self.manager.handsUpTimeOut = handsUpTimeOut
    }
    
    @objc public func updateHandsUp(state: AgoraHandsUpOCState) {
        
        var swiftState = AgoraHandsUpState.none
        if (state == .handsUp) {
            swiftState = .handsUp
        } else if(state == .handsDown) {
            swiftState = .handsDown
        } else if(state == .disabled) {
            swiftState = .disabled
        }
        self.manager.handsUpState = swiftState
    }
}

extension AgoraHandsUpManagerOC: AgoraHandsUpDelegate {
    public func onHandsClicked(currentState: AgoraHandsUpState) {
        
        var ocState = AgoraHandsUpOCState.none
        if (currentState == .handsUp) {
            ocState = .handsUp
        } else if(currentState == .handsDown) {
            ocState = .handsDown
        }
        
        self.delegate?.onHandsClicked(currentState: ocState)
    }
    
    public func onHandsUpTimeOut() {
        self.delegate?.onHandsUpTimeOut()
    }
}
