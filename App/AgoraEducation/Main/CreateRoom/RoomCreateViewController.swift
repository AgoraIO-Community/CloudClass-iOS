//
//  RoomCreateViewController.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/9/5.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit

class RoomCreateViewController: UIViewController {
    
    private let kSectionRoomType = 0
    private let kSectionRoomSubType = 1
    private let kSectionTime = 2
    private let kSectionMoreSetting = 3
        
    private let backImageView = UIImageView(image: UIImage())
    
    private let closeButton = UIButton(type: .custom)
    
    private let titleLabel = UILabel()
    
    private let tableView = UITableView(frame: .zero,
                                        style: .plain)
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 152,
                                 height: 78)
        layout.minimumInteritemSpacing = 9
        layout.scrollDirection = .horizontal
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
}
// MARK: - Actions
private extension RoomCreateViewController {
    @objc func onClickCancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc func onClickCreate(_ sender: UIButton) {
        dismiss(animated: true)
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
            return 3
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
            return cell
        } else if indexPath.section == kSectionRoomSubType {
            let cell = tableView.dequeueReusableCell(withClass: RoomSubTypeInfoCell.self)
            return cell
        } else if indexPath.section == kSectionTime {
            let cell = tableView.dequeueReusableCell(withClass: RoomTimeInfoCell.self)
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
        return indexPath.section == kSectionRoomSubType
    }
    
}
// MARK: - Collection View Call Back
extension RoomCreateViewController: UICollectionViewDelegate,
                                    UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: RoomTypeInfoCell.self,
                                                      for: indexPath)
        return cell
    }
    
    
}
// MARK: - Creations
private extension RoomCreateViewController {
    func createViews() {
        view.addSubview(backImageView)
        
        closeButton.addTarget(self,
                              action: #selector(onClickCancel(_:)),
                              for: .touchUpInside)
        view.addSubview(closeButton)
        
        titleLabel.text = "Create Classroom"
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        
        actionContentView.backgroundColor = UIColor.white
        view.addSubview(actionContentView)
        
        createButton.addTarget(self,
                               action: #selector(onClickCancel(_:)),
                               for: .touchUpInside)
        view.addSubview(createButton)
        
        cancelButton.addTarget(self,
                               action: #selector(onClickCancel(_:)),
                               for: .touchUpInside)
        view.addSubview(cancelButton)
        
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
            make?.right.equalTo()(30)
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
