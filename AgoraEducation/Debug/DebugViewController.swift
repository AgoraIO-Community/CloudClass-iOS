//
//  DebugViewController.swift
//  AgoraEducation
//
//  Created by SRS on 2021/2/16.
//  Copyright © 2021 Agora. All rights reserved.
//

import UIKit
import AgoraEduSDK
import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraWidget

@objcMembers class DebugViewController: UIViewController {
    private var alertView: AgoraAlertView?
    @IBOutlet weak var roomId: UITextField!
    @IBOutlet weak var userId: UITextField!
    @IBOutlet weak var roomName: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var picker: UIDatePicker!
    @IBOutlet weak var duration: UITextField!
    
    @IBOutlet weak var updateListLabel: UILabel!
    @IBOutlet weak var downLabel: UILabel!
    @IBOutlet weak var clearLabel: UILabel!
    
    fileprivate var startTime: Int?

    fileprivate var scenes: [WhiteScene] = []
    fileprivate var resourceName: String = ""
    fileprivate var resourceUuid: String = ""
    fileprivate var scenePath: String = ""
    fileprivate var downURL: String = ""
    
    private lazy var popBtn: UIButton = {
        var popBtn = UIButton(frame: CGRect(x: 300, y: 200, width: 100, height: 50))
        popBtn.setTitle("LoginVC", for: .normal)
        popBtn.setTitleColor(.white, for: .normal)
        popBtn.backgroundColor = UIColor(hexString: "C0D6FF")
        popBtn.addTarget(self, action: #selector(onPopDebugVC), for: .touchUpInside)
        return popBtn
    }()
    
    public weak var mainVC: MainViewController?
    
    public var downProcess: CGFloat = 0 {
        didSet {
            self.downLabel.text = "下载中：\(String(format:"%.2f", downProcess))"
        }
    }
    public var downCompleteSuccess: Bool = false {
        didSet {
            self.downLabel.text = downCompleteSuccess ? "下载成功" : "下载失败"
        }
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
        self.startTime = Int(timeInterval * 1000)
    
        picker.addTarget(self, action: #selector(selectValue), for: UIControl.Event.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIDevice.current.setValue(UIDeviceOrientation.landscapeRight.rawValue, forKey: "orientation")
    }
    
    fileprivate func joinRoom(_ type: AgoraEduRoomType) {

        var __startTime: NSNumber?
        if self.startTime != nil {
            __startTime = NSNumber(value: self.startTime!)
        }

        var __duration: NSNumber?
        let __durationStr = self.duration.text ?? ""
        if let value = Int(__durationStr) {
            __duration = NSNumber(value: value)
        }

        let roomUuid = self.roomId.text ?? ""
        let userUuid = self.userId.text ?? ""
        
        let roomName = (self.roomName.text ?? "")
        let userName = (self.userName.text ?? "")
        
        let rtmToken = TokenBuilder.buildToken(KeyCenter.appId(),
                                               appCertificate: KeyCenter.appCertificate(),
                                               userUuid: userUuid)
        
        let config = AgoraEduLaunchConfig(userName: userName,
                                          userUuid: userUuid,
                                          roleType: .student,
                                          roomName: roomName,
                                          roomUuid: roomUuid,
                                          roomType: type,
                                          token: rtmToken,
                                          startTime: __startTime,
                                          duration: __duration,
                                          boardRegion: nil)

        if alertView == nil {
            alertView = AgoraUtils.showLoading(message: "")
        }
        
        AgoraClassroomSDK.launch(config,
                           delegate: self)
        
//        let countDown = AgoraExtAppConfiguration(appIdentifier: "io.agora.countdown",
//                                              extAppClass: CountDownExtApp.self,
//                                              frame: UIEdgeInsets(top: 0,
//                                                                  left: 0,
//                                                                  bottom: 0,
//                                                                  right: 0),
//                                              language: "zh")
//        let apps = [countDown]
//        AgoraEduSDK.registerExtApps(apps)
    }
    
    @IBAction func join1V1Room(_ sender: Any) {
        self.joinRoom(AgoraEduRoomType.type1V1)
    }
    
    @IBAction func joinSmallRoom(_ sender: Any) {
        self.joinRoom(AgoraEduRoomType.typeSmall)
    }
    
    @IBAction func joinLectureRoom(_ sender: UIButton) {
        self.joinRoom(AgoraEduRoomType.typeLecture)
    }
    
    @IBAction func updateWareList(_ sender: Any) {
        let url = "http://api-solutions-dev.bj2.agoralab.co/scene/apps/f488493d1886435f963dfb3d95984fd4/v1/rooms/courseware0/users/liyang1/properties/resources"
        let token = "eyJhbGciOiJIUzI1NiJ9.eyJwcmltYXJ5U3RyZWFtVXVpZCI6IjE5NjU3ODQ1MzgiLCJhcHBJZCI6ImY0ODg0OTNkMTg4NjQzNWY5NjNkZmIzZDk1OTg0ZmQ0IiwidXNlclV1aWQiOiJsaXlhbmcxIiwicm9vbVV1aWQiOiJjb3Vyc2V3YXJlMCIsImlhdCI6MTYxMzEzMjE0Mn0.ZqBsGg-fEpBNM-ZB7yA4meWwIPX0eq4pildVwkUrCd4"
        
        self.updateListLabel.text = "更新中"
        
        TokenBuilder.boardResources(url, token: token) {[weak self] (scenes, resourceName, resourceUuid, scenePath, downURL) in
            
            self?.scenes = scenes
            self?.resourceName = resourceName
            self?.scenePath = scenePath
            self?.downURL = downURL
            self?.updateListLabel.text = "更新完成"
            
            let courseware = AgoraEduCourseware(resourceName: resourceName, resourceUuid: resourceUuid, scenePath: scenePath, scenes: scenes, resourceUrl: downURL)
            AgoraClassroomSDK.configCoursewares([courseware])

        } failure: {[weak self] (error) in
            self?.updateListLabel.text = "更新失败"
        }
    }
    @IBAction func downWareList(_ sender: Any) {
        
        self.downLabel.text = "下载中"
    
        AgoraClassroomSDK.downloadCoursewares(self)
    }
    @IBAction func clearWareList(_ sender: Any) {
        
        self.clearLabel.text = "清除中"
        
        DispatchQueue.global(qos: .userInitiated).async {
                let basePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
                let path = "\(basePath)/AgoraDownload/"
                try? FileManager.default.removeItem(atPath: path)
            // back to the main thread
            DispatchQueue.main.async {
                self.clearLabel.text = "清除完成"
            }
        }
    }
    
    @objc fileprivate func selectValue(){
        self.startTime = Int(picker.date.timeIntervalSince1970 * 1000)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    @objc fileprivate func onPopDebugVC() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
}

// MARK: AgoraEduClassroomDelegate
extension DebugViewController: AgoraEduClassroomDelegate {
    public func classroom(_ classroom: AgoraEduClassroom, didReceivedEvent event: AgoraEduEvent) {
        if alertView != nil {
            alertView?.removeFromSuperview()
        }
    }
}

extension DebugViewController: AgoraEduCoursewareDelegate {
    func courseware(_ courseware: AgoraEduCourseware, didProcessChanged process: Float) {
        self.downProcess = CGFloat(process)
    }
    
    func courseware(_ courseware: AgoraEduCourseware, didCompleted error: Error?) {
        self.downCompleteSuccess = (error == nil)
    }
}
