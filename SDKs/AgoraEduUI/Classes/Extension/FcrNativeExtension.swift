//
//  AgoraAppleExtension.swift
//  AgoraUIEduBaseViews
//
//  Created by Cavan on 2021/3/17.
//

import AgoraUIBaseViews
import AgoraWidget
import UIKit

func ValueTransform<Result>(value: Any?,
                            result: Result.Type) -> Result? {
    if let `value` = value {
        return (value as? Result)
    } else {
        return nil
    }
}

func ValueTransform<Result: RawRepresentable>(enumValue: Any?,
                                              result: Result.Type) -> Result? where Result.RawValue == Int {
    guard let intValue = ValueTransform(value: enumValue,
                                        result: Int.self) else {
        return nil
    }
    
    if let value = Result.init(rawValue: intValue) {
        return value
    } else {
        return nil
    }
}

protocol FcrAlert where Self: UIViewController {
    func showAlert(title: String,
                   contentList: [String],
                   actions: [AgoraAlertAction])
}

extension FcrAlert {
    func showAlert(title: String = "",
                   contentList: [String],
                   actions: [AgoraAlertAction]) {
        let alert = UIConfig.alert
        
        let alertController = AgoraAlert()
        
        alertController.backgroundColor = alert.backgroundColor
        alertController.lineColor = alert.sepLine.backgroundColor
        alertController.shadowColor = alert.shadow.color
        alertController.titleColor = alert.title.color
        alertController.buttonColor = alert.button.normalTitleColor
        alertController.normalContentColor = alert.message.normalColor
        alertController.selectedContentColor = alert.message.selectedColor
        alertController.unselectedOptionImage = alert.message.uncheckedImage
        alertController.selectedOptionImage = alert.message.checkedImage
        
        alertController.show(title: title,
                             contentList: contentList,
                             actions: actions,
                             in: self)
    }
}

// MARK: - Bundle
extension Bundle {
    class func edu_ui_bundle() -> Bundle {
        return Bundle.agora_bundle("AgoraEduUI") ?? Bundle.main
    }
}

extension UIImage {
    class func edu_ui_image(_ named: String) -> UIImage? {
        let bundle = Bundle.edu_ui_bundle()
        return UIImage(named: named,
                       in: bundle,
                       compatibleWith: nil)
    }
}

extension String {
    static func edu_ui_localized_replacing_x() -> String {
        return "{xxx}"
    }
    
    static func edu_ui_localized_replacing_y() -> String {
        return "{yyy}"
    }
    
    func edu_ui_localized() -> String {
        guard let eduBundle = Bundle.agora_bundle("AgoraEduUI") else {
            return ""
        }
        
        if let language = agora_ui_language,
           let languagePath = eduBundle.path(forResource: language,
                                             ofType: "lproj"),
           let bundle = Bundle(path: languagePath) {
            
            return bundle.localizedString(forKey: self,
                                          value: nil,
                                          table: nil)
        } else {
            let text = eduBundle.localizedString(forKey: self,
                                                 value: nil,
                                                 table: nil)
            
            return text
        }
    }
}

// 将 AgoraWidgetInfo.syncFrame 转化为 具体是显示在界面上的 frame
extension AgoraWidgetFrame {
    func rectInView(_ view: UIView) -> CGRect {
        let ratioWidth = self.width
        let rationHeight = self.height
        let xaxis = self.x
        let yaxis = self.y
        
        let displayWidth = ratioWidth * view.frame.width
        let displayHeight = rationHeight * view.frame.height
        
        let MEDx = view.frame.width - displayWidth
        let MEDy = view.frame.height - displayHeight
        
        let displayX = xaxis * MEDx
        let displayY = yaxis * MEDy
        
        let displayFrame = CGRect(x: displayX,
                                  y: displayY,
                                  width: displayWidth,
                                  height: displayHeight)
        return displayFrame
    }
    
    func displayFrameFromSyncFrame(superView: UIView,
                                   displayWidth: CGFloat,
                                   displayHeight: CGFloat) -> CGRect {
        let xaxis = self.x
        let yaxis = self.y
        
        let MEDx = superView.frame.width - displayWidth
        let MEDy = superView.frame.height - displayHeight
        
        let displayX = xaxis * MEDx
        let displayY = yaxis * MEDy
        
        let displayFrame = CGRect(x: displayX,
                                  y: displayY,
                                  width: displayWidth,
                                  height: displayHeight)
        return displayFrame
    }
    
    func isFullScreen() -> Bool {
        return (self.width == 1 &&
                self.height == 1)
    }
}

extension CGRect {
    func syncFrameInView(_ view: UIView) -> AgoraWidgetFrame {
        let MEDx = view.width - self.size.width
        let MEDy = view.height - self.size.height
        
        let xaxis = (MEDx == 0) ? 0: (self.minX / MEDx)
        let yaxis = (MEDy == 0) ? 0: (self.minY / MEDy)
        
        let displayWidth = (view.width == 0) ? 0 : (self.width / view.width)
        let displayHeight = (view.height == 0) ? 0 : (self.height / view.height)
        
        let syncFrame = AgoraWidgetFrame(x: xaxis,
                                         y: yaxis,
                                         z: 2,
                                         width: displayWidth,
                                         height: displayHeight)
        return syncFrame
    }
}

/** 尺寸适配*/
// 以375*812作为缩放标准（设计图都为iPhoneX）
fileprivate var kScale: CGFloat = {
    let width = max(UIScreen.main.bounds.width,
                    UIScreen.main.bounds.height)
    let height = min(UIScreen.main.bounds.width,
                     UIScreen.main.bounds.height)
    
    if width / height > 667.0 / 375.0 {
        return height / 375.0
    } else {
        return width / 667.0
    }
}()

fileprivate let kPad = UIDevice.current.userInterfaceIdiom == .pad

struct AgoraFit {
    static func scale(_ value: CGFloat) -> CGFloat {
        return value * kScale
    }
    
    static func os(phone: CGFloat,
                   pad: CGFloat) -> CGFloat {
        return kPad ? pad : phone
    }
}

// MARK: - Code
protocol Convertable: Codable {
    
}

extension Convertable {
    func toDictionary() -> Dictionary<String, Any>? {
        var dic: Dictionary<String,Any>?
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self)
            dic = try JSONSerialization.jsonObject(with: data,
                                                   options: .allowFragments) as? Dictionary<String, Any>
        } catch {
            // TODO: error handle
            print(error)
        }
        return dic
    }
}

extension Decodable {
    public static func decode(_ dic: [String : Any]) -> Self? {
        guard JSONSerialization.isValidJSONObject(dic),
              let data = try? JSONSerialization.data(withJSONObject: dic,
                                                      options: []),
              let model = try? JSONDecoder().decode(Self.self,
                                                    from: data) else {
                  return nil
              }
        return model
    }
}

extension Dictionary {
    func jsonString() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self,
                                                     options: .prettyPrinted) else {
            return nil
        }

        guard let jsonString = String(data: data,
                                      encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}

extension Dictionary where Key == String, Value == Any {
    func keyPath<Result>(_ path: String,
                         result: Result.Type) -> Result? {
        let array = path.components(separatedBy: ".")
        
        var latestDic: [String: Any]?
        
        // 数组越界保护
        let end = array.count - 2
        let endIndex = (end <= 0 ? 0 : end)
        
        if array.count == 1 {
            let key = array[0]
            
            return ValueTransform(value: self[key],
                                  result: Result.self)
        }
        
        for i in 0...endIndex {
            let key = array[i]
        
            if let dic = latestDic {
                let newLatestDic = ValueTransform(value: dic[key],
                                                  result: [String: Any].self)
                
                latestDic = newLatestDic
            } else {
                latestDic = ValueTransform(value: self[key],
                                           result: [String: Any].self)
            }
            
            if latestDic == nil {
                return nil
            }
        }
        
        guard let dic = latestDic,
              let lastKey = array.last else {
            return nil
        }
        
        return ValueTransform(value: dic[lastKey],
                              result: Result.self)
    }
    
    func keyPath<Result: RawRepresentable>(_ path: String,
                                           enumResult: Result.Type) -> Result? where Result.RawValue == Int {
        let array = path.components(separatedBy: ".")
        
        var latestDic: [String: Any]?
        
        let endIndex = array.count - 2
        
        for i in 0...endIndex {
            let key = array[i]
            
            latestDic = ValueTransform(value: key,
                                       result: [String: Any].self)
            
            if let _ = latestDic {
                return nil
            }
        }
        
        guard let dic = latestDic,
              let lastKey = array.last else {
            return nil
        }
        
        return ValueTransform(enumValue: dic[lastKey],
                              result: Result.self)
    }
}

extension String {
    func json() -> [String: Any]? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }

        return data.dic()
    }
    
    func toArr() -> [Any]? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        
        return data.toArr()
    }
}

extension Data {
    func dic() -> [String: Any]? {
        guard let object = try? JSONSerialization.jsonObject(with: self,
                                                             options: [.mutableContainers]) else {
            return nil
        }

        guard let dic = object as? [String: Any] else {
            return nil
        }

        return dic
    }
    
    func toArr() -> [Any]? {
        guard let object = try? JSONSerialization.jsonObject(with: self,
                                                             options: [.mutableContainers]) else {
            return nil
        }

        guard let arr = object as? [Any] else {
            return nil
        }
        
        return arr
    }
}

extension UICollectionViewFlowLayout {
    func copyLayout() -> UICollectionViewFlowLayout {
        let new = UICollectionViewFlowLayout()
        
        new.minimumLineSpacing = minimumLineSpacing
        new.minimumInteritemSpacing = minimumInteritemSpacing
        new.itemSize = itemSize
        new.estimatedItemSize = estimatedItemSize
        new.scrollDirection = scrollDirection
        
        new.headerReferenceSize = headerReferenceSize
        new.footerReferenceSize = footerReferenceSize
        new.sectionInset = sectionInset
        
        if #available(iOS 11.0, *) {
            new.sectionInsetReference = sectionInsetReference
        }
        
        new.sectionHeadersPinToVisibleBounds = sectionHeadersPinToVisibleBounds
        new.sectionFootersPinToVisibleBounds = sectionFootersPinToVisibleBounds
        
        return new
    }
}
