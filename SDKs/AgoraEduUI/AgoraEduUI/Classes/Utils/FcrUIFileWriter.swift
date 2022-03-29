//
//  FcrFileWriter.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/3/29.
//

import UIKit

class FcrUIFileWriter: NSObject {
    override init() {
        super.init()
        removeFolder(path: folder())
        createFolder(path: folder())
    }
    
    var byteLimit: Int64 = 0
    var writeLength: Int64 = 0
    var handle: FileHandle?
    var queue = DispatchQueue(label: "io.agora.ui.file.thread")
    
    func write(data: NSData,
               to file: String) {
        queue.async { [weak self] in
            self?._write(data: data,
                         to: file)
        }
    }
    
    func _write(data: NSData,
                to file: String) {
        if handle == nil {
            let filePath = folder() + "/" + file
            createFile(path: filePath)
            handle = FileHandle(forWritingAtPath: filePath)
        }
        
        if byteLimit != 0 {
            if byteLimit > writeLength {
                writeLength += Int64(data.length)
            } else {
                return
            }
        }
        
        handle?.write(data as Data)
    }
    
    func folder() -> String {
        let caches = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                         .userDomainMask,
                                                         true).first
        let name = "AgoraPCM"
        let path = caches! + "/" + name
        return path
    }
    
    func createFile(path: String) {
        try? FileManager.default.createFile(atPath: path,
                                            contents: nil,
                                            attributes: nil)
    }
    
    func createFolder(path: String) {
        try? FileManager.default.createDirectory(atPath: path,
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)
    }
    
    func removeFolder(path: String) {
        try? FileManager.default.removeItem(atPath: path)
    }
}
