//
//  AgoraWidgetsExtension.swift
//  AgoraWidgets
//
//  Created by Cavan on 2021/7/21.
//

import Foundation
import AgoraUIEduBaseViews

extension Dictionary {
    func jsonString() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self,
                                                    options: JSONSerialization.WritingOptions.prettyPrinted) else {
            return nil
        }
        
        guard let jsonString = String(data: data,
                                      encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}

extension String {
    func json() -> [String: Any]? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        
        return data.json()
    }
}

extension Data {
    func json() -> [String: Any]? {
        guard let object = try? JSONSerialization.jsonObject(with: self,
                                                             options: [.mutableContainers]) else {
            return nil
        }
        
        guard let dic = object as? [String: Any] else {
            return nil
        }
        
        return dic
    }
}

public func GetWidgetImage(object: NSObject,
                           _ name: String) -> UIImage? {
    let resource = "AgoraWidgets"
    return UIImage.agora_bundle(object: object,
                                resource: resource,
                                name: name)
}

public func GetWidgetLocalizableString(object: NSObject,
                                       key: String) -> String {
    let resource = "AgoraWidgets"
    return String.agora_localized_string(key,
                                         object: object,
                                         resource: resource)
}