//
//  AgoraCloudWidgetModel.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/2/7.
//

// MARK: - Config
//enum AgoraCloudWidgetSignal: Convertable {
//    case openCourseware(AgoraCloudWidgetCoursewareModel)
//    case CloseCloud
//
//    private enum CodingKeys: CodingKey {
//        case openCourseware
//        case CloseCloud
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        if let _ = try? container.decodeNil(forKey: .CloseCloud) {
//            self = .CloseCloud
//        } else if let value = try? container.decode(AgoraCloudWidgetCoursewareModel.self,
//                                                    forKey: .openCourseware) {
//            self = .openCourseware(value)
//        } else {
//            throw DecodingError.dataCorrupted(
//                .init(
//                    codingPath: container.codingPath,
//                    debugDescription: "invalid data"
//                )
//            )
//        }
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//
//        switch self {
//        case .CloseCloud:
//            try container.encodeNil(forKey: .CloseCloud)
//        case .openCourseware(let x):
//            try container.encode(x,
//                                 forKey: .openCourseware)
//        }
//    }
//
//    func toMessageString() -> String? {
//        guard let dic = self.toDictionary(),
//           let str = dic.jsonString() else {
//            return nil
//        }
//        return str
//    }
//
//}

//struct AgoraCloudWidgetCoursewareModel: Convertable {
//    var resourceUuid: String
//    var resourceName: String
//    var resourceUrl: String
//    var taskUuid: String?
//    var prefix: String?
//
//    var ext: String
//    var scenes: [AgoraCloudWidgetConvertedFile]?
//    var convert: Bool?
//
//    func toBoard() -> AgoraBoardWidgetCoursewareInfo {
//        let info = AgoraBoardWidgetCoursewareInfo(resourceUuid: self.resourceUuid,
//                                                  resourceName: self.resourceName,
//                                                  resourceUrl: self.resourceUrl,
//                                                  taskUuid: self.taskUuid,
//                                                  prefix: self.prefix,
//                                                  scenes: self.scenes?.toBoard(),
//                                                  convert: self.convert,
//                                                  ext: self.ext)
//        return info
//    }
//}

//struct AgoraCloudWidgetConvertedFile: Convertable {
//    var name: String
//    /// 图片的 URL 地址。
//    var src: String
//    /// 图片的 URL 宽度。单位为像素。
//    var width: Float
//    /// 图片的 URL 高度。单位为像素。
//    var height: Float
//    /// 预览图片的 URL 地址
//    var preview: String?
//}
//
//extension String {
//    func toCloudSignal() -> AgoraCloudWidgetSignal? {
//        guard let dic = self.json(),
//              let signal = try AgoraCloudWidgetSignal.decode(dic) else {
//                  return nil
//              }
//
//        return signal
//    }
//}
//
// where Element == AgoraCloudWidgetConvertedFile {
//    func toBoard() -> [AgoraBoardWidgetWhiteScene] {
//        var boardArr = [AgoraBoardWidgetWhiteScene]()
//        for item in self {
//            let boardScene = AgoraBoardWidgetWhiteScene(name: item.name,
//                                                        src: item.src,
//                                                        width: item.width,
//                                                        height: item.height,
//                                                        previewURL: item.preview)
//            boardArr.append(boardScene)
//        }
//        return boardArr
//    }
//}
