//
//  AgoraCloudVM+Info.swift
//  AgoraWidgets
//
//  Created by ZYP on 2021/10/23.
//

import Foundation
import AgoraEduContext

extension AgoraCloudVM {
    typealias SelectedType = AgoraCloudTopView.SelectedType
    typealias Config = CloudServerApi.Config
    
    struct Info: Equatable {
        let viewInfo: AgoraCloudListView.Info
        let courseware: AgoraEduContextCourseware
        
        init(fileItem: CloudServerApi.FileItem) {
            let resourceName = fileItem.resourceName
            let resourceUuid = fileItem.resourceUuid
            let scenePath = "/" + fileItem.resourceName
            let resourceURL = fileItem.url
            let ext = fileItem.ext
            let size = fileItem.size
            let updateTime = fileItem.updateTime
            let scenes = fileItem.taskProgress.convertedFileList.map { conFile -> AgoraEduContextWhiteScene in
                let ppt = AgoraEduContextWhitePptPage(src: conFile.ppt.src,
                                                      width: conFile.ppt.width,
                                                      height: conFile.ppt.height,
                                                      previewURL: conFile.ppt.preview)
                return AgoraEduContextWhiteScene(name: conFile.name,
                                                 ppt: ppt)
            }
            
            self.courseware = AgoraEduContextCourseware(resourceName: resourceName,
                                                        resourceUuid: resourceUuid,
                                                        scenePath: scenePath,
                                                        resourceURL: resourceURL,
                                                        scenes: scenes,
                                                        ext: ext,
                                                        size: size,
                                                        updateTime: updateTime)
            self.viewInfo = AgoraCloudListView.Info(fileItem: fileItem)
        }
        
        init(courseware: AgoraEduContextCourseware) {
            self.courseware = courseware
            self.viewInfo = AgoraCloudListView.Info(courseware: courseware)
        }
        
        var uuid: String {
            return courseware.resourceUuid
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.uuid == rhs.uuid
        }
    }
}

extension AgoraCloudListView.Info {
    init(fileItem: CloudServerApi.FileItem) {
        let imageName = AgoraCloudListView.Info.imageName(ext: fileItem.ext)
        let name = fileItem.resourceName
        let sizeString = fileItem.size.toDataSizeUnitString
        let timeString = (fileItem.updateTime/1000.0).formatString
        self.imageName = imageName
        self.name = name
        self.sizeString = sizeString
        self.timeString = timeString
    }
    
    init(courseware: AgoraEduContextCourseware) {
        let imageName = AgoraCloudListView.Info.imageName(ext: "ext")
        let name = courseware.resourceName
        let sizeString = courseware.size.toDataSizeUnitString
        let timeString = (courseware.updateTime/1000.0).formatString
        self.imageName = imageName
        self.name = name
        self.sizeString = sizeString
        self.timeString = timeString
    }
    
    static func imageName(ext: String) -> String {
        switch ext {
        case "pptx", "ppt", "pptm":
            return "format-PPT"
        case "docx", "doc":
            return "format-word"
        case "xlsx", "xls", "csv":
            return "format-excel"
        case "pdf":
            return "format-pdf"
        case "jpeg", "jpg", "png", "bmp":
            return "format-pic"
        case "mp3", "wav", "wma", "aac", "flac", "m4a", "oga", "opu":
            return "format-audio"
        case "mp4", "3gp", "mgp", "mpeg", "3g2", "avi", "flv", "wmv", "h264",
            "m4v", "mj2", "mov", "ogg", "ogv", "rm", "qt", "vob", "webm":
            return "format-video"
        default:
            return "format-unknown"
        }
    }
}

extension Double {
    /// will return 970B or 1.3K or 1.3M
    var toDataSizeUnitString: String {
        if self < 1024 {
            return "\(self.roundTo(places: 1))" + "B"
        }
        else if self < (1024 * 1024) {
            return "\((self/1024).roundTo(places: 1))" + "K"
        }
        else {
            return "\((self/(1024 * 1024)).roundTo(places: 1))" + "M"
        }
    }
}

extension TimeInterval {
    /// YY-MM-DD HH:mm:ss
    var formatString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-DD HH:mm:ss"
        let date = Date(timeIntervalSince1970: self)
        return formatter.string(from: date)
    }
}

extension Double {
    /// Rounds the double to decimal places value
    
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
