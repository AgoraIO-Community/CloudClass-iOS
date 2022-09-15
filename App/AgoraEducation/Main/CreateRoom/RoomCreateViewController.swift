//
//  RoomCreateViewController.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/9/5.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit
import AgoraEduCore
#if canImport(AgoraClassroomSDK_iOS)
import AgoraClassroomSDK_iOS
#else
import AgoraClassroomSDK
#endif

private extension AgoraEduServiceType {
    func icon() -> UIImage? {
        switch self {
        case .livePremium:
            return UIImage(named: "fcr_room_create_premium")
        case .liveStandard:
            return UIImage(named: "fcr_room_create_standard")
        case .fusion:
            return UIImage(named: "fcr_room_create_fusion")
        default:
            return nil
        }
    }
    
    func title() -> String? {
        switch self {
        case .livePremium:
            return "fcr_create_premium_title".ag_localized()
        case .liveStandard:
            return "fcr_create_standard_title".ag_localized()
        case .fusion:
            return "fcr_create_fusion_title".ag_localized()
        default:
            return nil
        }
    }
    
    func subTitle() -> String? {
        switch self {
        case .livePremium:
            return "fcr_create_premium_subtitle".ag_localized()
        case .liveStandard:
            return "fcr_create_standard_subtitle".ag_localized()
        case .fusion:
            return "fcr_create_fusion_subtitle".ag_localized()
        default:
            return nil
        }
    }
}

class RoomCreateViewController: UIViewController {
    
    private let kSectionRoomType = 0
    private let kSectionRoomSubType = 1
    private let kSectionTime = 2
    private let kSectionMoreSetting = 3
        
    private let backImageView = UIImageView(image: UIImage(named: "fcr_room_create_bg"))
    
    private let closeButton = UIButton(type: .custom)
    
    private let titleLabel = UILabel()
    
    private let tableView = UITableView(frame: .zero,
                                        style: .plain)
    
    private let roomTypes: [AgoraEduCoreRoomType] = [.small, .lecture, .oneToOne]
    
    private var roomName: String?
    
    private var selectedRoomType: AgoraEduCoreRoomType = .small {
        didSet {
            guard selectedRoomType != oldValue else {
                return
            }
            updateSubRoomType()
        }
    }
    
    private var selectedSubRoomType: AgoraEduServiceType?
    
    private var selectDate = Date()
    
    private var subRoomTypes = [AgoraEduServiceType]()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 122,
                                 height: 78)
        layout.minimumInteritemSpacing = 9
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 20,
                                           left: 16,
                                           bottom: 0,
                                           right: 16)
        let view = UICollectionView(frame: .zero,
                                    collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.register(cellWithClass: RoomTypeInfoCell.self)
        return view
    }()
    
    private let actionContentView = UIView()
    
    private let createButton = UIButton(type: .custom)
    
    private let cancelButton = UIButton(type: .custom)
    
    static func showCreateRoom(complete: (() -> Void)?) {
        guard let root = UIApplication.shared.keyWindow?.rootViewController
        else {
            return
        }
        let vc = RoomCreateViewController()
        vc.modalPresentationStyle = .fullScreen
        root.present(vc, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(hex: 0xF8FAFF)
        createViews()
        createConstrains()
    }
    
    public override var shouldAutorotate: Bool {
        return true
    }
    
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIDevice.current.agora_is_pad ? .landscapeRight : .portrait
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.current.agora_is_pad ? .landscapeRight : .portrait
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        super.touchesBegan(touches,
                           with: event)
        
        UIApplication.shared.keyWindow?.endEditing(true)
    }
}
// MARK: - Actions
private extension RoomCreateViewController {
    @objc func onClickCancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc func onClickCreate(_ sender: UIButton) {
        guard let name = roomName else {
            return
        }
        AgoraLoading.loading()
        selectDate.second = 0
        selectDate.millisecond = 0
        let startTime = UInt(selectDate.timeIntervalSince1970)
        let endTime = startTime + 30*60
        FcrOutsideClassAPI.createClassRoom(roomName: name,
                                           roomType: selectedRoomType.rawValue,
                                           startTime: startTime * 1000,
                                           endTine: endTime * 1000,
                                           roomProperties: nil) { rsp in
            AgoraLoading.hide()
            self.dismiss(animated: true)
        } onFailure: { str in
            AgoraLoading.hide()
            AgoraToast.toast(message: str,
                             type: .error)
        }
    }
    
    func updateSubRoomType() {
        if selectedRoomType == .lecture {
            subRoomTypes = [.livePremium, .liveStandard, .fusion]
            selectedSubRoomType = .livePremium
        } else {
            subRoomTypes = []
        }
        tableView.reloadData()
    }
    
    func showTimeSelection() {
        RoomCreateTimeAlertController.showTimeSelection(in: self,
                                                        from: Date()) { date in
            self.selectDate = date
            self.tableView.reloadData()
        }
    }
}
// MARK: - RoomBaseInfoCell Call Back
extension RoomCreateViewController: RoomBaseInfoCellDelegate {
    func onRoomNameChanged(text: String) {
        roomName = text
    }
}
// MARK: - Table View Call Back
extension RoomCreateViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if section == kSectionRoomType {
            return 1
        } else if section == kSectionRoomSubType {
            return subRoomTypes.count
        } else if section == kSectionTime {
            return 1
        } else if section == kSectionMoreSetting {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == kSectionRoomType {
            let cell = tableView.dequeueReusableCell(withClass: RoomBaseInfoCell.self)
            cell.optionsView = collectionView
            cell.delegate = self
            return cell
        } else if indexPath.section == kSectionRoomSubType {
            let cell = tableView.dequeueReusableCell(withClass: RoomSubTypeInfoCell.self)
            let subRoomType = subRoomTypes[indexPath.row]
            cell.iconView.image = subRoomType.icon()
            cell.titleLabel.text = subRoomType.title()
            cell.subTitleLabel.text = subRoomType.subTitle()
            cell.aSelected = (subRoomType == selectedSubRoomType)
            return cell
        } else if indexPath.section == kSectionTime {
            let cell = tableView.dequeueReusableCell(withClass: RoomTimeInfoCell.self)
            cell.startDate = selectDate
            return cell
        } else if indexPath.section == kSectionMoreSetting {
            let cell = tableView.dequeueReusableCell(withClass: RoomMoreInfoCell.self)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withClass: RoomMoreInfoCell.self)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath,
                              animated: false)
        if indexPath.section == kSectionRoomSubType {
            selectedSubRoomType = subRoomTypes[indexPath.row]
            tableView.reloadData()
        } else if indexPath.section == kSectionTime {
            showTimeSelection()
        } else if indexPath.section == kSectionMoreSetting {
            
        }
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == kSectionRoomType {
            return 200
        } else if indexPath.section == kSectionRoomSubType {
            return 60
        } else if indexPath.section == kSectionTime {
            return 94
        } else if indexPath.section == kSectionMoreSetting {
            return 120
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return (
            indexPath.section == kSectionRoomSubType ||
            indexPath.section == kSectionTime
        )
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        UIApplication.shared.keyWindow?.endEditing(true)
    }
}
// MARK: - Collection View Call Back
extension RoomCreateViewController: UICollectionViewDelegate,
                                    UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return roomTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: RoomTypeInfoCell.self,
                                                      for: indexPath)
        let roomType = roomTypes[indexPath.row]
        switch roomType {
        case .small:
            cell.imageView.image = UIImage(named: "fcr_room_create_small_bg")
            cell.titleLabel.text = "fcr_create_small_title".ag_localized()
            cell.subTitleLabel.text = "fcr_create_small_detail".ag_localized()
            cell.aSelected = (roomType == selectedRoomType)
        case .lecture:
            cell.imageView.image = UIImage(named: "fcr_room_create_lecture_bg")
            cell.titleLabel.text = "fcr_create_lecture_title".ag_localized()
            cell.subTitleLabel.text = "fcr_create_lecture_detail".ag_localized()
            cell.aSelected = (roomType == selectedRoomType)
        case .oneToOne:
            cell.imageView.image = UIImage(named: "fcr_room_create_1v1_bg")
            cell.titleLabel.text = "fcr_create_onetoone_title".ag_localized()
            cell.subTitleLabel.text = "fcr_create_onetoone_detail".ag_localized()
            cell.aSelected = (roomType == selectedRoomType)
        default: break
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath,
                                    animated: false)
        selectedRoomType = roomTypes[indexPath.row]
        collectionView.reloadData {
            collectionView.scrollToItem(at: indexPath,
                                        at: .centeredHorizontally,
                                        animated: true)
        }
    }
}
// MARK: - Creations
private extension RoomCreateViewController {
    func createViews() {
        view.addSubview(backImageView)
        
        closeButton.setImage(UIImage(named: "fcr_room_create_cancel"),
                             for: .normal)
        closeButton.addTarget(self,
                              action: #selector(onClickCancel(_:)),
                              for: .touchUpInside)
        view.addSubview(closeButton)
        
        titleLabel.text = "fcr_create_room".ag_localized()
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        
        actionContentView.backgroundColor = UIColor.white
        view.addSubview(actionContentView)
        
        createButton.setTitle("fcr_create_submit".ag_localized(),
                              for: .normal)
        createButton.addTarget(self,
                               action: #selector(onClickCreate(_:)),
                               for: .touchUpInside)
        createButton.setTitleColor(.white,
                                   for: .normal)
        createButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        createButton.layer.cornerRadius = 23
        createButton.clipsToBounds = true
        createButton.backgroundColor = UIColor(hex: 0x357BF6)
        actionContentView.addSubview(createButton)
        
        cancelButton.setTitle("fcr_create_cancel".ag_localized(),
                              for: .normal)
        cancelButton.addTarget(self,
                               action: #selector(onClickCancel(_:)),
                               for: .touchUpInside)
        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cancelButton.setTitleColor(.black,
                                   for: .normal)
        cancelButton.layer.cornerRadius = 23
        cancelButton.clipsToBounds = true
        cancelButton.backgroundColor = UIColor(hex: 0xF8F8F8)
        actionContentView.addSubview(cancelButton)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellWithClass: RoomBaseInfoCell.self)
        tableView.register(cellWithClass: RoomSubTypeInfoCell.self)
        tableView.register(cellWithClass: RoomTimeInfoCell.self)
        tableView.register(cellWithClass: RoomMoreInfoCell.self)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
    }
    
    func createConstrains() {
        closeButton.mas_makeConstraints { make in
            make?.width.height().equalTo()(44)
            make?.left.equalTo()(16)
            make?.top.equalTo()(44)
        }
        backImageView.mas_makeConstraints { make in
            make?.left.top().right().equalTo()(0)
        }
        titleLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(closeButton)
            make?.left.right().equalTo()(0)
        }
        actionContentView.mas_makeConstraints { make in
            make?.left.right().bottom().equalTo()(0)
            if #available(iOS 11.0, *) {
                make?.top.equalTo()(self.view.mas_safeAreaLayoutGuideBottom)?.offset()(-90)
            } else {
                make?.height.equalTo()(90)
            }
        }
        createButton.mas_makeConstraints { make in
            make?.top.equalTo()(16)
            make?.right.equalTo()(-30)
            make?.height.equalTo()(46)
            make?.width.equalTo()(190)
        }
        cancelButton.mas_makeConstraints { make in
            make?.centerY.equalTo()(createButton)
            make?.right.equalTo()(createButton.mas_left)?.offset()(-15)
            make?.height.equalTo()(46)
            make?.width.equalTo()(110)
        }
        tableView.mas_makeConstraints { make in
            make?.top.equalTo()(99)
            make?.left.right().equalTo()(0)
            make?.bottom.equalTo()(actionContentView.mas_top)
        }
    }
}
