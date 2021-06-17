//
//  AgoraAgoraUserListView.swift
//  AgoraUIEduBaseViews
//
//  Created by LYY on 2021/3/8.
//

import AgoraUIBaseViews

public class AgoraUserListView : AgoraBaseUIView {    
    public enum UserCellType: String{
        case `default` = "None"
        case big = "BigCellId"
        case small = "SmallCellId"
    }
    
    public var teacherName : String? {
        didSet {
            teacherNameLabel.text = teacherName
        }
    }
    
    public let StudentCellID: String
    public var closeTouchBlock: (() -> Void)?
    
    public private(set) lazy var studentTable : AgoraBaseUITableView = {
        let studentTable = AgoraBaseUITableView()
        studentTable.tableFooterView = AgoraBaseUIView(frame: .zero)
        studentTable.backgroundColor = .white
        studentTable.register(AgoraUserCell.self,
                             forCellReuseIdentifier: StudentCellID)
        studentTable.separatorInset = UIEdgeInsets(top: 0,
                                                  left: 0,
                                                  bottom: 0,
                                                  right: 0)
        studentTable.layoutMargins = UIEdgeInsets(top: 0,
                                                 left: 0,
                                                 bottom: 0,
                                                 right: 0)
        return studentTable
    }()

    // MARK: lazy load
    private lazy var titleView : AgoraBaseUIView = {
        let titleView = AgoraBaseUIView()
        titleView.backgroundColor = .init(r: 249,
                                          g: 249,
                                          b: 252)
        
        let titleLabel = AgoraBaseUILabel()
        titleLabel.text = AgoraKitLocalizedString("UserListMainTitle")
        titleLabel.font = .boldSystemFont(ofSize: 14)
        titleLabel.textColor = .black
        titleView.addSubview(titleLabel)
        
        titleLabel.agora_x = 19
        titleLabel.agora_y = 10
        titleLabel.sizeToFit()
        
        let lineV = AgoraBaseUIView()
        lineV.backgroundColor = UIColor(rgb: 0xE3E3EC)
        titleView.addSubview(lineV)
        lineV.agora_x = 0
        lineV.agora_right = 0
        lineV.agora_height = 1
        lineV.agora_bottom = 0
       
        let btn = AgoraBaseUIButton(type: .custom)
        btn.setImage(AgoraKitImage("chat_min"),
                     for: .normal)
        btn.addTarget(self,
                      action: #selector(onCloseTouchEvent),
                      for: .touchUpInside)
        titleView.addSubview(btn)
        
        btn.agora_center_y = 0
        btn.agora_right = 15
        btn.agora_resize(24, 24)
        
        return titleView
    }()
    
    private lazy var teacherInfo : AgoraBaseUIView = {
        let teacherInfo = AgoraBaseUIView()
        teacherInfo.backgroundColor = .white
        
        let teacherTitle = AgoraBaseUILabel()
        teacherTitle.text = AgoraKitLocalizedString("UserListTeacherName")
        teacherTitle.font = .boldSystemFont(ofSize: 13)
        teacherTitle.textColor = .init(r: 123,
                                       g: 136,
                                       b: 160)
        teacherTitle.sizeToFit()
        
        teacherInfo.addSubview(teacherTitle)
        teacherInfo.addSubview(teacherNameLabel)
        
        teacherTitle.agora_x = 22
        teacherTitle.agora_y = 11
        
        let stringSize = teacherTitle.text!.agoraKitSize(font: .boldSystemFont(ofSize: 13))
        
        teacherNameLabel.agora_x = teacherTitle.agora_x + stringSize.width + 2
        teacherNameLabel.agora_y = 11
        
        return teacherInfo
    }()
    
    private lazy var teacherNameLabel : AgoraBaseUILabel = {
        let name = AgoraBaseUILabel()
        name.font = .boldSystemFont(ofSize: 13)
        name.textColor = .init(r: 25,
                               g: 25,
                               b: 25)
        return name
    }()
    
    private lazy var listHeader : AgoraBaseUIView = {
        let headerView = AgoraBaseUIView()
        
        headerView.backgroundColor = .init(r: 249,
                                           g: 249,
                                           b: 252)
        
        let smallTextArr: [String : CGFloat] = [
            AgoraKitLocalizedString("UserListName") : 22,
            AgoraKitLocalizedString("UserListCoVideo") : 105,
            AgoraKitLocalizedString("UserListBoard") : 184,
            AgoraKitLocalizedString("UserListCamera") : 250,
            AgoraKitLocalizedString("UserListMicro") : 329,
            AgoraKitLocalizedString("UserListChat") : 408,
            AgoraKitLocalizedString("UserListReward") : 474];
        
        let bigTextArr: [String : CGFloat] = [
            AgoraKitLocalizedString("UserListName") : 22,
            AgoraKitLocalizedString("UserListCamera") : 104,
            AgoraKitLocalizedString("UserListMicro") : 173,
            AgoraKitLocalizedString("UserListChat") : 242];
        
        var textArr: [String : CGFloat]?
        
        switch cellType {
        case .big:
            textArr = bigTextArr
        case .small:
            textArr = smallTextArr
        default:
            textArr = nil
        }
        
        guard let arr = textArr else {
            return headerView
        }
        
        arr.forEach { (text,agoraX) in
            let label = AgoraBaseUILabel()
            label.text = text
            headerView.addSubview(label)
            
            label.agora_x = CGFloat(agoraX)
            label.font = .boldSystemFont(ofSize: 13)
            label.textColor = .init(r: 123,
                                    g: 136,
                                    b: 160)
            label.agora_width = 80
            label.agora_y = 11
        }
        
        let lineUp = AgoraBaseUIView()
        lineUp.backgroundColor = UIColor(rgb: 0xE3E3EC)
        let lineDown = AgoraBaseUIView()
        lineDown.backgroundColor = UIColor(rgb: 0xE3E3EC)
        
        headerView.addSubview(lineUp)
        headerView.addSubview(lineDown)
        lineUp.agora_x = 0
        lineUp.agora_right = 0
        lineUp.agora_height = 1
        lineUp.agora_y = 0
        
        lineDown.agora_x = 0
        lineDown.agora_right = 0
        lineDown.agora_height = 1
        lineDown.agora_bottom = 0
        
        return headerView
    }()
    
    private lazy var boarderView: AgoraBaseUIView = {
        let boarderView = AgoraBaseUIView()
        boarderView.backgroundColor = .clear
        boarderView.isUserInteractionEnabled = false
        boarderView.layer.borderWidth = 1
        boarderView.layer.borderColor = UIColor(rgb: 0xE3E3EC).cgColor
        boarderView.clipsToBounds = true
        boarderView.layer.cornerRadius = 6
        return boarderView
    }()
    
    private let cellType: UserCellType
    
    // MARK: init
    public init(frame: CGRect,
                cellType: UserCellType) {
        self.cellType = cellType
        StudentCellID = cellType.rawValue
        
        super.init(frame:frame)
        
        initView()
        initLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: touch event
    @objc fileprivate func onCloseTouchEvent() {
        self.closeTouchBlock?()
    }
}

// MARK: - private
private extension AgoraUserListView {
    func initView() {
        backgroundColor = .clear
        
        layer.shadowColor = UIColor(red: 0.18,
                                         green: 0.25,
                                         blue: 0.57,
                                         alpha: 0.15).cgColor
        layer.shadowOffset = CGSize(width: 0,
                                         height: 2)
        layer.shadowOpacity = 1
        layer.shadowRadius = 6

        addSubview(titleView)
        addSubview(teacherInfo)
        addSubview(listHeader)
        addSubview(studentTable)
        addSubview(boarderView)
    }
    
    func initLayout() {
        titleView.agora_x = 0
        titleView.agora_y = 0
        titleView.agora_right = 0
        titleView.agora_height = 40

        teacherInfo.agora_x = 0
        teacherInfo.agora_y = titleView.agora_height
        teacherInfo.agora_right = 0
        teacherInfo.agora_height = 40

        listHeader.agora_x = 0
        listHeader.agora_y = teacherInfo.agora_y + teacherInfo.agora_height
        listHeader.agora_right = 0
        listHeader.agora_height = 40

        studentTable.agora_x = 0
        studentTable.agora_y = listHeader.agora_y + listHeader.agora_height
        studentTable.agora_right = 0
        studentTable.agora_bottom = 1
        
        boarderView.agora_x = 0
        boarderView.agora_right = 0
        boarderView.agora_y = 0
        boarderView.agora_bottom = 0
    }
}
