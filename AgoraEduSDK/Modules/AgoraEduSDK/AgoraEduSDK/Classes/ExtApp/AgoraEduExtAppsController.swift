//
//  AgoraEduExtAppsController.swift
//  AgoraEduSDK
//
//  Created by Cavan on 2021/4/7.
//  Copyright © 2021 Agora. All rights reserved.
//

import UIKit
import AgoraUIBaseViews
import AgoraExtApp
import AgoraEduExtApp
import AgoraEduContext

@objcMembers public class AgoraEduExtAppsController: AgoraExtAppsController {
    private weak var urlGroup: AgoraURLGroup?
    private weak var contextPool: AgoraEduContextPool?

    public init(urlGroup: AgoraURLGroup,
                contextPool: AgoraEduContextPool) {
        self.urlGroup = urlGroup
        self.contextPool = contextPool
        super.init()
    }
}

// MARK: - AgoraExtAppDelegate
extension AgoraEduExtAppsController {
    
    public override func getContextWithAppIdentifier(_ appIdentifier: String,
                                                     localUserInfo userInfo: AgoraExtAppUserInfo,
                                                     roomInfo: AgoraExtAppRoomInfo,
                                                     properties: [AnyHashable : Any],
                                                     language: String) -> AgoraExtAppContext {
        let context = AgoraEduExtAppContext(appIdentifier: appIdentifier,
                                            localUserInfo: userInfo,
                                            roomInfo: roomInfo,
                                            properties: properties,
                                            language: language)
        context.contextPool = self.contextPool
        return context
    }
    
    public override func extApp(_ app: AgoraBaseExtApp,
                       updateProperties properties: [AnyHashable : Any],
                       success: @escaping AgoraExtAppCompletion,
                       fail: @escaping AgoraExtAppErrorCompletion) {
        guard let `properties` = properties as? [String: Any] else {
            return
        }
        
        let parameters = ["properties": properties]
        propertiesRequest(.put,
                          appIdentifier: app.appIdentifier,
                          parameters: parameters,
                          success: success,
                          fail: fail)
    }
    
    public override func extApp(_ app: AgoraBaseExtApp,
                       deleteProperties keys: [String],
                       success: @escaping AgoraExtAppCompletion,
                       fail: @escaping AgoraExtAppErrorCompletion) {
        let parameters = ["properties": keys]
        propertiesRequest(.deleteBody,
                          appIdentifier: app.appIdentifier,
                          parameters: parameters,
                          success: success,
                          fail: fail)
    }
}

extension AgoraEduExtAppsController: AgoraController {
    public func viewWillAppear() {
        
    }
    
    public func viewDidLoad() {
        
    }
    
    public func viewDidAppear() {
        
    }
    
    public func viewWillDisappear() {
        
    }
    
    public func viewDidDisappear() {
        
    }
}

private extension AgoraEduExtAppsController {
    func propertiesRequest(_ httpType: HttpType,
                           appIdentifier: String,
                           parameters: [String: Any],
                           success: @escaping AgoraExtAppCompletion,
                           fail: @escaping AgoraExtAppErrorCompletion) {
        func request(roomUuid: String) {
            guard let `urlGroup` = urlGroup else {
                fatalError()
            }
            
            let url = urlGroup.extApp(roomUuid: roomUuid,
                                      appIdentifier: appIdentifier.extAppFormat())
            let headers = urlGroup.headers()
            
            AgoraHTTPManager.fetchDispatch(httpType,
                                           url: url,
                                           parameters: parameters,
                                           headers: headers,
                                           parseClass: AgoraBaseModel.self) { (_) in
                success();
            } failure: { [weak self] (error, httpCode) in
                guard let `self` = self else {
                    return
                }
                
                let extError = self.generateExtAppError(with: error,
                                                        httpCode: httpCode)
                fail(extError)
            }
        }
        
        dataSource?.appsController(self, needUserInfo: { (_) in
            
        }, needRoomInfo: { [weak self] (roomInfo) in
            guard let `self` = self else {
                return
            }
            
            request(roomUuid: roomInfo.roomUuid)
        })
    }
    
    func generateExtAppError(with error: Error,
                             httpCode: Int) -> AgoraExtAppError {
        var errorCode: Int
        let nsError = error as NSError
        
        if httpCode == 200 {
            errorCode = nsError.code
        } else {
            errorCode = httpCode
        }
        
        let extError = AgoraExtAppError(code: errorCode,
                                        message: nsError.localizedDescription)
        return extError
    }
}

fileprivate extension String {
    func extAppFormat() -> String {
        return self.replacingOccurrences(of: ".",
                                         with: "_")
    }
}
