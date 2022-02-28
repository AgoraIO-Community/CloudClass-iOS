//
//  AgoraCloudWidgetModel.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/2/7.
//

let kCloudWidgetId = "AgoraCloudWidget"
// MARK: - Config
enum AgoraCloudWidgetSignal {
    case OpenCoursewares(AgoraCloudWidgetCoursewareModel)
    case CloseCloud
    
    var rawValue: Int {
        switch self {
        case .OpenCoursewares(let _):   return 0
        case .CloseCloud:   return 1
        }
    }
    
    static func getType(rawValue: Int) -> Convertable.Type? {
        switch rawValue {
        case 0:   return AgoraCloudWidgetCoursewareModel.self
        default:  return nil
        }
    }
    
    static func makeSignal(rawValue: Int,
                           body: Convertable?) -> AgoraCloudWidgetSignal? {
        switch rawValue {
        case 0:
            if let x = body as? AgoraCloudWidgetCoursewareModel {
                return .OpenCoursewares(x)
            }
        case 1:
            return .CloseCloud
        default:
            break
        }
        return nil
    }
}

struct AgoraCloudWidgetCoursewareModel: Convertable {
    var resourceUuid: String
    var resourceName: String
    var scenes: [AgoraCloudWidgetConvertedFile]
    var convert: Bool?
    
    func toBoard() -> AgoraBoardWidgetCoursewareInfo {
        let info = AgoraBoardWidgetCoursewareInfo(resourceUuid: self.resourceUuid,
                                                  resourceName: self.resourceName,
                                                  scenes: self.scenes.toBoard(),
                                                  convert: self.convert)
        return info
    }
}

struct AgoraCloudWidgetConvertedFile: Convertable {
    public var name: String
    public var ppt: AgoraCloudWidgetPptPage
}

struct AgoraCloudWidgetPptPage: Convertable {
    /// 图片的 URL 地址。
    var src: String
    /// 图片的 URL 宽度。单位为像素。
    var width: Float
    /// 图片的 URL 高度。单位为像素。
    var height: Float
    /// 预览图片的 URL 地址
    var preview: String?
    
    func toBoard() -> AgoraBoardWidgetWhitePptPage {
        return AgoraBoardWidgetWhitePptPage(src: src,
                                            width: width,
                                            height: height,
                                            previewURL: preview)
    }
}

extension String {
    func toCloudSignal() -> AgoraCloudWidgetSignal? {
        guard let dic = self.json(),
              let signalRaw = dic["signal"] as? Int else {
            return nil
              }
        
        if signalRaw == AgoraCloudWidgetSignal.CloseCloud.rawValue {
            return .CloseCloud
        }
        
        if let bodyDic = dic["body"] as? [String:Any],
           let type = AgoraCloudWidgetSignal.getType(rawValue: signalRaw),
           let obj = try type.decode(bodyDic) {
            return AgoraCloudWidgetSignal.makeSignal(rawValue: signalRaw,
                                                     body: obj)
        }
        
        return nil
    }
}

extension Array where Element == AgoraCloudWidgetConvertedFile {
    func toBoard() -> [AgoraBoardWidgetWhiteScene] {
        var boardArr = [AgoraBoardWidgetWhiteScene]()
        for item in self {
            let boardScene = AgoraBoardWidgetWhiteScene(name: item.name,
                                                        ppt: item.ppt.toBoard())
            boardArr.append(boardScene)
        }
        return boardArr
    }
}
