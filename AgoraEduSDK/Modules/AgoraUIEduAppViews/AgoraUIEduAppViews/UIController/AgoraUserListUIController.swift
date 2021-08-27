//
//  AgoraUserListUIController.swift
//  AgoraUIEduAppViews
//
//  Created by SRS on 2021/4/18.
//


import UIKit
import AgoraUIEduBaseViews
import AgoraUIBaseViews
import AgoraEduContext

protocol AgoraUserListUIControllerDelegate: NSObjectProtocol {
    func userListUIController(_ controller: AgoraUserListUIController,
                              didStateChanged close: Bool)
}

class AgoraUserListUIController: NSObject, AgoraUIController {
    var containerView = AgoraUIControllerContainer(frame: .zero)
    
    private var userContext: AgoraEduUserContext? {
        return contextProvider?.controllerNeedUserContext()
    }
    
    private(set) var viewType: AgoraEduContextAppType
    private weak var contextProvider: AgoraControllerContextProvider?
    private weak var eventRegister: AgoraControllerEventRegister?
    private weak var delegate: AgoraUserListUIControllerDelegate?

    // View
    private lazy var userListView: AgoraUserListView = {
        var cellType: AgoraUserListView.UserCellType
        
        switch viewType {
        case .lecture:
            cellType = .big
        case .small:
            cellType = .small
        default:
            fatalError()
        }
        
        return AgoraUserListView(frame: .zero,
                                 cellType: cellType)
        
    }()
    
    // DataSource
    private var studentModels: [AgoraEduContextUserDetailInfo] = [] {
        didSet {
            userListView.studentTable.reloadData()
        }
    }
    
    init(viewType: AgoraEduContextAppType,
         contextProvider: AgoraControllerContextProvider,
         eventRegister: AgoraControllerEventRegister,
         delegate: AgoraUserListUIControllerDelegate) {
        self.viewType = viewType
        self.contextProvider = contextProvider
        self.eventRegister = eventRegister
        self.delegate = delegate
        
        super.init()
        initViews()
        initLayout()
        observeEvent(register: eventRegister)
        observeUI()
    }
    
    func updateUserListViewVisible() {
        let isUserListHidden = !containerView.isHidden
        containerView.isHidden = isUserListHidden
        
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
    
    func observeEvent(register: AgoraControllerEventRegister) {
        register.controllerRegisterUserEvent(self)
    }
    
    func observeUI() {
        userListView.studentTable.delegate = self
        userListView.studentTable.dataSource = self
        
        userListView.closeTouchBlock = { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.containerView.isHidden = true
            self.delegate?.userListUIController(self,
                                                didStateChanged: true)
        }
    }
    
    func sortListForBigClass(oriList: [AgoraEduContextUserDetailInfo]) -> [AgoraEduContextUserDetailInfo]? {
        guard let sortedArr: [[AgoraEduContextUserDetailInfo]] = oriList.sepToNumAndCohost() else {
            return nil
        }
        
        var finalList: [AgoraEduContextUserDetailInfo] = [AgoraEduContextUserDetailInfo]()
        sortedArr.forEach { (list) in
            guard var arr = list as? [AgoraEduContextUserDetailInfo] else {
                return
            }
            arr.sort { (info_0, info_1) -> Bool in
                let name_0 = info_0.user.userName
                let name_1 = info_1.user.userName
                
                let str_0 = name_0.isIncludeChinese() ? name_0.transformToChar() : name_0
                let str_1 = name_1.isIncludeChinese() ? name_1.transformToChar() : name_1
                return str_0.localizedCompare(str_1) == ComparisonResult(rawValue: -1)
            }
            finalList.append(contentsOf: arr)
        }
        
        return finalList
    }
}

// MARK: - AgoraEduUserHandler
extension AgoraUserListUIController: AgoraEduUserHandler {
    // 更新人员信息列表，只显示在线人员信息
    public func onUpdateUserList(_ list: [AgoraEduContextUserDetailInfo]) {
        var finalList = list
        
        if viewType == .lecture,
           let sortedList = sortListForBigClass(oriList: list) {
            finalList = sortedList
        }
        
        var studentList = [AgoraEduContextUserDetailInfo]()
        
        finalList.forEach { (info) in
                switch info.user.role {
                case .student:
                    studentList.append(info)
                case .teacher:
                    userListView.teacherName = info.user.userName
                default:
                    break
                }
        }
        
        studentModels = studentList
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
        cell.info = studentModel
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
        let user = studentModels[index]
        let mute = user.enableVideo
        userContext?.muteVideo(mute)
    }
    
    func userCell(_ cell: AgoraUserCell,
                  didPresseAudioMuteAt index: Int) {
        let user = studentModels[index]
        let mute = user.enableAudio
        userContext?.muteAudio(mute)
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
    func sepToNumAndCohost() -> [[AgoraEduContextUserDetailInfo]]? {
        guard let oriArr = self as? [AgoraEduContextUserDetailInfo] else {
            return nil
        }
        
        var arrOnNum = [AgoraEduContextUserDetailInfo]()
        var arrOnNone = [AgoraEduContextUserDetailInfo]()
        var arrOffNum = [AgoraEduContextUserDetailInfo]()
        var arrOffNone = [AgoraEduContextUserDetailInfo]()
        
        oriArr.forEach { (info) in
            guard let name = info.user.userName as? String else {
                return
            }
            
            if info.coHost {
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
