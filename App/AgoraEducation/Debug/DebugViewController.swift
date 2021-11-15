//
//  DebugViewController.swift
//  AgoraEducation
//
//  Created by SRS on 2021/2/16.
//  Copyright © 2021 Agora. All rights reserved.
//

#if canImport(AgoraClassroomSDK_iOS)
import AgoraClassroomSDK_iOS
#else
import AgoraClassroomSDK
#endif
import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraWidgets
import AgoraWidget
import ChatWidget
import YYModel
import UIKit

@objcMembers class DebugViewController: UIViewController {
    @IBOutlet weak var roomId: UITextField!
    @IBOutlet weak var userId: UITextField!
    @IBOutlet weak var roomName: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var picker: UIDatePicker!
    @IBOutlet weak var duration: UITextField!
    
    @IBOutlet weak var updateListLabel: UILabel!
    @IBOutlet weak var downLabel: UILabel!
    @IBOutlet weak var clearLabel: UILabel!
    @IBOutlet weak var encryptionKey: UITextField!
    @IBOutlet weak var encryptionMode: UITextField!
    @IBOutlet weak var regionField: UITextField!
    
    private lazy var popBtn: UIButton = {
        var popBtn = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 150,
                                            y: UIScreen.main.bounds.height - 100,
                                            width: 100,
                                            height: 50))
        popBtn.setTitle("LoginVC",
                        for: .normal)
        popBtn.setTitleColor(.white,
                             for: .normal)
        popBtn.backgroundColor = UIColor(hexString: "C0D6FF")
        popBtn.addTarget(self,
                         action: #selector(onPopDebugVC),
                         for: .touchUpInside)
        return popBtn
    }()
    
    private var downProcess: CGFloat = 0 {
        didSet {
            downLabel.text = "下载中：\(String(format:"%.2f", downProcess))"
        }
    }
    
    private var downCompleteSuccess: Bool = false {
        didSet {
            downLabel.text = downCompleteSuccess ? "下载成功" : "下载失败"
        }
    }
    
    private var alertView: AgoraAlertView?
    private var startTime: Int?
    private var classroom: AgoraEduClassroom?
    private let tokenBuilder = TokenBuilder()
    private let debugCourware = DebugCourware()
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIDevice.current.setValue(UIDeviceOrientation.landscapeRight.rawValue,
                                  forKey: "orientation")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(popBtn)
        picker.calendar = Calendar.current
        picker.locale = Locale(identifier: "zh_GB");
        picker.timeZone = TimeZone.current;
        picker.datePickerMode = .time;
        
        // 默认未来5分钟开始
        let timeInterval = Date().timeIntervalSince1970 + 5 * 60
        let date = Date(timeIntervalSince1970: timeInterval)
        picker.setDate(date, animated: true)
        startTime = Int(timeInterval * 1000)
        
        picker.addTarget(self,
                         action: #selector(selectValue),
                         for: UIControl.Event.valueChanged)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    @IBAction func join1V1Room(_ sender: Any) {
        joinRoom(.oneToOne)
    }
    
    @IBAction func joinSmallRoom(_ sender: Any) {
        joinRoom(.small)
    }
    
    @IBAction func joinLectureRoom(_ sender: UIButton) {
        joinRoom(.lecture)
    }
    
    @IBAction func updateWareList(_ sender: Any) {
        setCoursewares()
    }
    
    @IBAction func downWareList(_ sender: Any) {
        downLabel.text = "下载中"
        AgoraClassroomSDK.downloadCoursewares(self)
    }
    
    @IBAction func clearWareList(_ sender: Any) {
        clearLabel.text = "清除中"
        
        DispatchQueue.global(qos: .userInitiated).async {
            let basePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory,
                                                               FileManager.SearchPathDomainMask.userDomainMask,
                                                               true)[0]
            let path = "\(basePath)/AgoraDownload/"
            try? FileManager.default.removeItem(atPath: path)
            // back to the main thread
            DispatchQueue.main.async {
                self.clearLabel.text = "清除完成"
            }
        }
    }
    
    @objc private func selectValue(){
        startTime = Int(picker.date.timeIntervalSince1970 * 1000)
    }
    
    @objc private func onPopDebugVC() {
        navigationController?.popViewController(animated: true)
    }
}

private extension DebugViewController {
    func joinRoom(_ type: AgoraEduRoomType) {
        guard let `roomId` = roomId.text,
              let `userId` = userId.text,
              let durationString = duration.text,
              let durationInt = Int(durationString),
              let `startTime` = startTime,
              let `userName` = userName.text,
              let `roomName` = roomName.text else {
            return
        }
        
        var region: String
        
        if let text = regionField.text,
           text.count > 0 {
            region = text
        } else {
            region = "CN"
        }
        
        
        //        registerExtApps()
        
        if region.contains("CN") {
            let chat = AgoraWidgetConfiguration(with: ChatWidget.self,
                                                widgetId: "HyChatWidget")
            AgoraClassroomSDK.registerWidgets([chat])
        }
        
//        let sel = NSSelectorFromString("setBaseURL:");
//        let url = KeyCenter.hostURL()
//        AgoraClassroomSDK.perform(sel,
//                                  with: url)
        
        // roomUuid = roomName + classType
        let roomUuid = "\(roomId)\(type.rawValue)"
        
        // userUuid = userName + roleType
        let userUuid = "\(userId)\(AgoraEduRoleType.student.rawValue)"
        
        let duration = durationInt
        
        let roleType: AgoraEduRoleType = .student
        
        //        var encryptionConfig: AgoraEduMediaEncryptionConfig?
        //        if let key = self.inputParams.encryptKey ?? self.defaultParams.encryptKey,
        //           encryptionMode != .none {
        //            let tfModeValue = encryptionMode.rawValue
        //            if tfModeValue > 0 && tfModeValue <= 6 {
        //                encryptionConfig = AgoraEduMediaEncryptionConfig(mode: encryptionMode, key: key)
        //            }
        //        }
        let mediaOptions = AgoraEduMediaOptions(encryptionConfig: nil,
                                                cameraEncoderConfiguration: nil,
                                                latencyLevel: .ultraLow,
                                                videoState: .on,
                                                audioState: .on)
        
        requestToken(region: region,
                     userUuid: userUuid) { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            
            let appId = response.appId
            let rtmToken = response.rtmToken
            let userUuid = response.userId
            let sdkConfig = AgoraClassroomSDKConfig(appId: appId)
            
            let launchConfig = AgoraEduLaunchConfig(userName: userName,
                                                    userUuid: userUuid,
                                                    roleType: roleType,
                                                    roomName: roomName,
                                                    roomUuid: roomUuid,
                                                    roomType: type,
                                                    token: rtmToken,
                                                    startTime: NSNumber(value: startTime),
                                                    duration: NSNumber(value: duration),
                                                    region: region,
                                                    mediaOptions: mediaOptions,
                                                    userProperties: nil,
                                                    boardFitMode: .retain)
            
            AgoraClassroomSDK.setConfig(sdkConfig)
            self.classroom = AgoraClassroomSDK.launch(launchConfig,
                                                      delegate: self)
        }
    }
    
    func requestToken(region: String,
                      userUuid: String,
                      completion: @escaping (TokenBuilder.ServerResp) -> ()) {
        if alertView == nil {
            alertView = AgoraUtils.showLoading(message: "")
        } else {
            alertView?.show(in: view)
        }
        
        tokenBuilder.buildByServer(region: region,
                                   userUuid: userUuid,
                                   environment: .dev,
                                   success: { (resp) in
                                    completion(resp)
                                   }, fail: { [weak self] (error) in
                                    guard let `self` = self else {
                                        return
                                    }
                                    self.alertView?.removeFromSuperview()
                                    AgoraUtils.showToast(message: error.localizedDescription)
                                   })
    }
}

// MARK: Fetch BoardResource
extension DebugViewController {
    func setCoursewares() {
        if let data = debugCourware.json.data(using: .utf8) {
            do {
                let dict = try JSONSerialization.jsonObject(with: data,
                                                            options: []) as? [String : Any]
                guard let data = dict?["data"] as? [String : Any],
                      let list = data["list"] as? [[String : Any]]  else {
                    return
                }
                
                var coursewares = [AgoraEduCourseware]()
                for dic in list {
                    if let resourceName = dic["resourceName"] as? String,
                       let resourceUuid = dic["resourceUuid"] as? String,
                       let resourceUrl = dic["url"] as? String,
                       let ext = dic["ext"] as? String,
                       let size = dic["size"] as? Double,
                       let updateTime = dic["updateTime"] as? Double,
                       let taskProgress = dic["taskProgress"] as? [String : Any],
                       let convertedFileList = taskProgress["convertedFileList"] as? [[String : Any]] {
                        let scenePath = "/" + resourceName
                        
                        var scenes = [AgoraEduBoardScene]()
                        for sceneDict in convertedFileList {
                            if let name = sceneDict["name"] as? String,
                               let ppt = sceneDict["ppt"] as? [String : Any],
                               let width = ppt["width"] as? CGFloat,
                               let height = ppt["height"] as? CGFloat,
                               let preview = ppt["preview"] as? String,
                               let src = ppt["src"] as? String {
                                let pptPage = AgoraEduPPTPage.init(source: src,
                                                                   previewURL: preview,
                                                                   size: CGSize(width: width, height: height))
                                let scene = AgoraEduBoardScene.init(name: name,
                                                                    pptPage: pptPage)
                                scenes.append(scene)
                            }
                        }
                        
                        let courseware = AgoraEduCourseware(resourceName: resourceName,
                                                            resourceUuid: resourceUuid,
                                                            scenePath: scenePath,
                                                            scenes: scenes,
                                                            resourceUrl: resourceUrl,
                                                            ext: ext,
                                                            size: size,
                                                            updateTime: updateTime)
                        coursewares.append(courseware)
                    }
                }
                
                AgoraClassroomSDK.configCoursewares(coursewares)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: AgoraEduClassroomDelegate
extension DebugViewController: AgoraEduClassroomDelegate {
    public func classroom(_ classroom: AgoraEduClassroom,
                          didReceivedEvent event: AgoraEduEvent) {
        guard let `alertView` = alertView else {
            return
        }
        
        alertView.removeFromSuperview()
    }
}

extension DebugViewController: AgoraEduCoursewareDelegate {
    func courseware(_ courseware: AgoraEduCourseware,
                    didProcessChanged process: Float) {
        downProcess = CGFloat(process)
    }
    
    func courseware(_ courseware: AgoraEduCourseware,
                    didCompleted error: Error?) {
        downCompleteSuccess = (error == nil)
    }
}
