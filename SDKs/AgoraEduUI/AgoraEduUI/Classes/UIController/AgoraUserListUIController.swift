//
//  AgoraUserListUIController.swift
//  AgoraEduUI
//
//  Created by SRS on 2021/4/18.
//

import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext

protocol AgoraUserListUIControllerDelegate: NSObjectProtocol {
    func controller(_ controller: AgoraUserListUIController,
                    didShowContainer show: Bool)
}

class AgoraUserListUIController: NSObject, AgoraUIController {
    var containerView = AgoraUIControllerContainer(frame: .zero)
    
    private var userContext: AgoraEduUserContext? {
        return contextProvider?.controllerNeedUserContext()
    }
    
    private var mediaContext: AgoraEduMediaContext? {
        return contextProvider?.controllerNeedMediaContext()
    }
    
    private(set) var viewType: AgoraEduContextRoomType
    private(set) var region: String
    private weak var contextProvider: AgoraControllerContextProvider?
    
    
    // View
    private lazy var userListView: AgoraUserListView = {
        var cellType: AgoraUserListView.UserCellType
        
        switch viewType {
        case .lecture:
            cellType = region == "CN" ? .bigCn : .bigNonCn
        case .small:
            cellType = region == "CN" ? .smallCn : .smallNonCn
        case .paintingSmall:
            cellType = region == "CN" ? .smallCn : .smallNonCn
        default:
            fatalError()
        }
        
        return AgoraUserListView(frame: .zero,
                                 cellType: cellType)
        
    }()
    
    // DataSource
    private var studentModels: [AgoraEduContextUserInfo] = [] {
        didSet {
            userListView.studentTable.reloadData()
        }
    }
    
    weak var delegate: AgoraUserListUIControllerDelegate?
    
    init(viewType: AgoraEduContextRoomType,
         contextProvider: AgoraControllerContextProvider,
         region: String) {
        self.viewType = viewType
        self.contextProvider = contextProvider
        self.region = region
        
        super.init()
        initViews()
        initLayout()
        observeUI()
    }
    
    func updateUserListViewVisible() {
        let isUserListHidden = !containerView.isHidden
        containerView.isHidden = isUserListHidden
        
        delegate?.controller(self,
                             didShowContainer: !containerView.isHidden)
        
        guard !isUserListHidden else {
            return
        }
        
        containerView.alpha = 0
        let transform = CGAffineTransform(scaleX: 0.3,
                                          y: 0.3)
        containerView.transform = transform
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut) {
            self.containerView.alpha = 1
            self.containerView.transform = CGAffineTransform(scaleX: 1.0,
                                                             y: 1.0)
            self.containerView.superview?.layoutIfNeeded()
        }
    }
}

private extension AgoraUserListUIController {
    func initViews() {
        containerView.backgroundColor = .clear
        containerView.addSubview(userListView)
        
        containerView.isHidden = true
    }

    func initLayout() {
        userListView.agora_x = 0
        userListView.agora_y = 0
        userListView.agora_right = 0
        userListView.agora_bottom = 0
    }

    func observeUI() {
        userListView.studentTable.delegate = self
        userListView.studentTable.dataSource = self
        
        userListView.closeTouchBlock = { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.containerView.isHidden = true
            
            self.delegate?.controller(self,
                                      didShowContainer: !self.containerView.isHidden)
        }
    }
    
    func sortListForBigClass(oriList: [AgoraEduContextUserInfo]?) -> [AgoraEduContextUserInfo]? {
        guard let list = oriList,
              let sortedArr: [[AgoraEduContextUserInfo]] = list.sepToNumAndCohost() else {
            return nil
        }
        
        var finalList: [AgoraEduContextUserInfo] = [AgoraEduContextUserInfo]()
        sortedArr.forEach { (list) in
            guard var arr = list as? [AgoraEduContextUserInfo] else {
                return
            }
            arr.sort { (info_0, info_1) -> Bool in
                let name_0 = info_0.userName
                let name_1 = info_1.userName
                
                let str_0 = name_0.isIncludeChinese() ? name_0.transformToChar() : name_0
                let str_1 = name_1.isIncludeChinese() ? name_1.transformToChar() : name_1
                return str_0.localizedCompare(str_1) == ComparisonResult(rawValue: -1)
            }
            finalList.append(contentsOf: arr)
        }
        
        return finalList
    }
    
    func updateUserList() {
        guard let `userContext` = userContext,
              let studentList = userContext.getUserList(role: .student) else {
            studentModels = [AgoraEduContextUserInfo]()
            return
        }

        var finalList = studentList
        
        // 大班课需要排序
        if viewType == .lecture,
           let sortedList = sortListForBigClass(oriList: studentList) {
            finalList = sortedList
        }
        
        studentModels = finalList
        
    }
}

// MARK: - AgoraEduUserHandler
extension AgoraUserListUIController: AgoraEduUserHandler {
    func onRemoteUserJoined(user: AgoraEduContextUserInfo) {
        if user.role == .teacher {
            userListView.teacherName = user.userName
        } else {
            updateUserList()
        }
    }
    func onRemoteUserLeft(user: AgoraEduContextUserInfo,
                          operator: AgoraEduContextUserInfo?,
                          reason: AgoraEduContextUserLeaveReason) {
        if user.role == .teacher {
            userListView.teacherName = ""
        } else {
            updateUserList()
        }
    }
    func onUserUpdated(user: AgoraEduContextUserInfo,
                       operator: AgoraEduContextUserInfo?) {
        if user.role == .teacher {
            userListView.teacherName = user.userName
        } else {
            updateUserList()
        }
    }
    func onUserRewarded(user: AgoraEduContextUserInfo,
                        rewardCount: Int,
                        operator: AgoraEduContextUserInfo) {
        updateUserList()
    }
}

// MARK: UITableViewDataSource
extension AgoraUserListUIController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: userListView.StudentCellID,
                                                 for: indexPath) as! AgoraUserCell
        
        let studentModel = studentModels[indexPath.row]
        cell.userName = studentModel.userName
        cell.coHostFlag = studentModel.isCoHost
        // TODO: boardGranted handle
//        cell.boardGrantedFlag = studentModel.boardGranted
        cell.rewardCount = studentModel.rewardCount
//        cell.updateSpecificCameraState(deviceState: studentModel.cameraState.rawValue,
//                                       enableVideo: studentModel.enableVideo,
//                                       isSelf: studentModel.isSelf)
//        cell.updateSpecificAudioState(deviceState: studentModel.microState.rawValue,
//                                      enableAudio: studentModel.enableAudio,
//                                      isSelf: studentModel.isSelf)
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate
extension AgoraUserListUIController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

// MARK: - AgoraUserCellDelegate
extension AgoraUserListUIController: AgoraUserCellDelegate {
    
    func userCell(_ cell: AgoraUserCell,
                  didPresseVideoMuteAt index: Int) {
//        let user = studentModels[index]
//        let mute = user.enableVideo
//
//        if mute {
//            mediaContext?.unpublishStream(streamUuid: user.streamUuid,
//                                          type: .video)
//        } else {
//            mediaContext?.publishStream(streamUuid: user.streamUuid,
//                                        type: .video)
//        }
    }
    
    func userCell(_ cell: AgoraUserCell,
                  didPresseAudioMuteAt index: Int) {
        let user = studentModels[index]
//        let mute = user.enableAudio
//        
//        if mute {
//            mediaContext?.unpublishStream(streamUuid: user.streamUuid,
//                                          type: .audio)
//        } else {
//            mediaContext?.publishStream(streamUuid: user.streamUuid,
//                                        type: .audio)
//        }
    }
    
    func userCell(_ cell: AgoraUserCell,
                  didPresseKickAt index: Int) {
        
    }
}

// MARK: - fileprivate
fileprivate extension String {
    /// 判断字符串中是否有中文
    func isIncludeChinese() -> Bool {
        for ch in self.unicodeScalars {
            if (0x4e00 < ch.value  && ch.value < 0x9fff) { return true } // 中文字符范围：0x4e00 ~ 0x9fff
        }
        return false
    }
    
    /// 将中文字符串转换为拼音
    func transformToChar() -> String {
        // 多音字替换
        let str = self.polyphoneStringHandle()
        
        let stringRef = NSMutableString(string: str) as CFMutableString
        // 转换为带音标的拼音
         CFStringTransform(stringRef,nil, kCFStringTransformToLatin, false)
        // 去掉音标（大大提高遍历的速度）
        CFStringTransform(stringRef, nil, kCFStringTransformStripCombiningMarks, false)
        let pinyin = stringRef as String
        return pinyin.replacingOccurrences(of: " ", with: "")
    }
    
    /// 多音字处理
    func polyphoneStringHandle() -> String {
        var replace: String?
        if self.hasPrefix("长") {replace = "chang"}
        if self.hasPrefix("沈") {replace = "shen"}
        if self.hasPrefix("厦") {replace = "xia"}
        if self.hasPrefix("地") {replace = "di"}
        if self.hasPrefix("重") {replace = "chong"}
        
        guard let rep = replace else {
            return self
        }

        let range = self.startIndex...self.index(self.startIndex, offsetBy: 0)
        return self.replacingCharacters(in: range, with: rep)
    }
    
    func beginWithNum() -> Bool {
        if self.first?.hexDigitValue ?? -1 >= 0 &&
            self.first?.hexDigitValue ?? -1 <= 9 {
            return true
        } else {
            return false
        }
    }
}

fileprivate extension Array {
    // 拆分为【已上台+首字符为数字】【已上台+首字符不为数字】【未上台+首字符为数字】【未上台+首字符不为数字】
    func sepToNumAndCohost() -> [[AgoraEduContextUserInfo]]? {
        guard let oriArr = self as? [AgoraEduContextUserInfo] else {
            return nil
        }
        
        var arrOnNum = [AgoraEduContextUserInfo]()
        var arrOnNone = [AgoraEduContextUserInfo]()
        var arrOffNum = [AgoraEduContextUserInfo]()
        var arrOffNone = [AgoraEduContextUserInfo]()
        
        oriArr.forEach { (info) in
            guard let name = info.userName as? String else {
                return
            }
            
            if info.isCoHost {
                if name.beginWithNum() {
                    arrOnNum.append(info)
                } else {
                    arrOnNone.append(info)
                }
            } else {
                if name.beginWithNum() {
                    arrOffNum.append(info)
                } else {
                    arrOffNone.append(info)
                }
            }
        }
        
        return [arrOnNone,arrOnNum,arrOffNone,arrOffNum]
    }
}
