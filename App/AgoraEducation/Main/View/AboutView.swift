//
//  AboutView.swift
//  AgoraEducation
//
//  Created by LYY on 2021/4/25.
//  Copyright © 2021 Agora. All rights reserved.
//

import Foundation
import AgoraUIBaseViews

@objcMembers public class AboutView: AgoraBaseUIView,
                                     UITableViewDataSource,
                                     UITableViewDelegate{
    private lazy var contentView: AgoraBaseUIView = {
        var contentView = AgoraBaseUIView()
        contentView.backgroundColor = LoginConfig.device == .iPad ? .white : UIColor(hexString: "F9F9FC")
        
        contentView.layer.cornerRadius = 8
        //        contentView.layer.backgroundColor = UIColor.white.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor(hexString: "ECECF1").cgColor
        
        contentView.layer.shadowColor = UIColor(red: 0.18, green: 0.25, blue: 0.57, alpha: 0.15).cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowRadius = 5
        
        return contentView
    }()
    
    private lazy var titleView: AgoraBaseUIView = {
        var titleView = AgoraBaseUIView()
        titleView.backgroundColor = .white
        titleView.layer.cornerRadius = 8
        
        var titleLabel = AgoraBaseUILabel()
        titleLabel.text = NSLocalizedString("About_title", comment: "")
        titleLabel.backgroundColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = LoginConfig.about_title_font
        titleLabel.textColor = UIColor(hexString: "191919")
        
        var backBtn = AgoraBaseUIButton()
        backBtn.addTarget(self, action: #selector(onTouchBack), for: .touchUpInside)
        
        titleView.addSubview(titleLabel)
        
        if LoginConfig.device == .iPad {
            titleLabel.agora_center_x = 0
            titleLabel.agora_center_y = 0
            
            backBtn.setTitle(NSLocalizedString("About_close", comment: ""), for: .normal)
            backBtn.setTitleColor(UIColor(hexString: "357BF6"), for: .normal)
            backBtn.titleLabel?.font = LoginConfig.about_title_font
            titleView.addSubview(backBtn)
            
            backBtn.agora_x = 20
            backBtn.agora_center_y = 0
            
            titleView.addBottomLine()
        } else {
            titleView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05).cgColor
            titleView.layer.shadowOffset = CGSize(width: 0, height: 1)
            titleView.layer.shadowOpacity = 1
            titleView.layer.shadowRadius = 1
            backBtn.setBackgroundImage(UIImage(named: "about_back"), for: .normal)
            
            titleView.addSubview(backBtn)
            
            titleLabel.agora_center_x = 0
            titleLabel.agora_bottom = 9
            
            backBtn.agora_x = 15
            backBtn.agora_bottom = 1
        }
        
        return titleView
    }()
    
    private lazy var infoTable: AgoraBaseUITableView = {
        var tab = AgoraBaseUITableView()
        tab.dataSource = self
        tab.delegate = self
        tab.showsVerticalScrollIndicator = false
        tab.showsHorizontalScrollIndicator = false
        tab.isScrollEnabled = false
        
        tab.tableFooterView = UIView(frame: .zero)
        tab.register(AboutTableCell.self, forCellReuseIdentifier: LoginConfig.About_cell_id)
        return tab
    }()
    
    private lazy var bottomLabel: AgoraBaseUILabel = {
        var label = AgoraBaseUILabel()
        label.text = NSLocalizedString("About_url", comment: "")
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(hexString: "7D8798")
        label.textAlignment = .center
        
        label.isHidden = LoginConfig.device == .iPad
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        initView()
        initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: touch event
    @objc func onTouchBack() {
        if LoginConfig.device == .iPad {
            removeFromSuperview()
        } else {
            UIView.animate(withDuration: TimeInterval.agora_animation) {[weak self] in
                    self?.agora_x = self?.frame.width ?? 0

                    self?.transform = CGAffineTransform(translationX: self?.frame.width ?? 0,
                                                        y: 0)
                    self?.layoutIfNeeded()
            } completion: {[weak self] (complete) in
                guard complete else {
                    return
                }
                self?.removeFromSuperview()
            }
        }
    }
    
    
    // MARK: UITableViewDataSource & UITableViewDelegate
    @objc public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LoginConfig.AboutInfoList.count
    }
    
    @objc public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tabCell = tableView.dequeueReusableCell(withIdentifier: LoginConfig.About_cell_id, for: indexPath) as! AboutTableCell
        if indexPath.row == (LoginConfig.AboutInfoList.count - 1) &&
            LoginConfig.device == .iPad {
            tabCell.separatorInset = UIEdgeInsets(top: 0,
                                                  left: 0,
                                                  bottom: 0,
                                                  right: UIScreen.main.bounds.width)
        } else {
            tabCell.separatorInset = UIEdgeInsets(top: LoginConfig.about_cell_height,
                                                  left: 10,
                                                  bottom: 0,
                                                  right: 10)
        }
        
        tabCell.setInfo(title: LoginConfig.AboutInfoList[indexPath.row].0, detail: LoginConfig.AboutInfoList[indexPath.row].1)
        
        return tabCell
    }
    
    @objc public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return LoginConfig.about_cell_height
    }
    
    @objc public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detail = LoginConfig.AboutInfoList[indexPath.row].1 else {
            return
        }
        
        if let detailUrl = detail as? URL {
            DispatchQueue.main.async {
                UIApplication.shared.open(detailUrl,
                                          options: [:]) { (complete) in
                    
                }
            }
        } else if let detailView = detail as? AgoraBaseUIView {
            addSubview(detailView)
            switch LoginConfig.device {
            case .iPhone_Big: fallthrough
            case .iPhone_Small:
                detailView.alpha = 1
                detailView.agora_x = 0
                detailView.agora_y = 0
                detailView.agora_right = 0
                detailView.agora_bottom = 0
                
                detailView.layoutIfNeeded()
                detailView.transform = CGAffineTransform(translationX: frame.width,
                                                         y: 0)
                UIView.animate(withDuration: TimeInterval.agora_animation,
                               delay: 0,
                               options: .transitionFlipFromLeft,
                               animations: {
                                detailView.agora_x = 0
                                detailView.agora_y = 0
                                detailView.agora_right = 0
                                detailView.agora_bottom = 0

                                detailView.transform = CGAffineTransform(translationX: 0,
                                                                         y: 0)
                                detailView.layoutIfNeeded()
                               }, completion: nil)
            case .iPad:
                detailView.alpha = 0
                detailView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                UIView.animate(withDuration: TimeInterval.agora_animation,
                               delay: 0,
                               usingSpringWithDamping: 0.5,
                               initialSpringVelocity: 0,
                               options: .curveEaseInOut,
                               animations: {
                                detailView.agora_x = 0
                                detailView.agora_y = 0
                                detailView.agora_right = 0
                                detailView.agora_bottom = 0
                                detailView.alpha = 1
                                detailView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                detailView.layoutIfNeeded()
                               }, completion: nil)
            }
            
        }
    }
}

// MARK: UI
extension AboutView {
    private func initView(){
        
        switch LoginConfig.device {
        case .iPhone_Big: fallthrough
        case .iPhone_Small:
            backgroundColor = .clear
            contentView.addSubview(bottomLabel)
        case .iPad:
            backgroundColor = UIColor.init(white: 1, alpha: 0.7)
        }
        addSubview(contentView)
        
        contentView.addSubview(titleView)
        contentView.addSubview(infoTable)
        contentView.addSubview(bottomLabel)
        
    }
    
    private func initLayout(){
        switch LoginConfig.device {
        case .iPhone_Big: fallthrough
        case .iPhone_Small: 
            contentView.agora_x = 0
            contentView.agora_y = 0
            contentView.agora_right = 0
            contentView.agora_bottom = 0
            
            bottomLabel.agora_bottom = 31
            bottomLabel.agora_center_x = 0
        case .iPad:
            contentView.agora_center_x = 0
            contentView.agora_center_y = 0
            contentView.agora_width = 420
            contentView.agora_height = 320
        }
        
        titleView.agora_x = 0
        titleView.agora_y = 0
        titleView.agora_right = 0
        titleView.agora_height = LoginConfig.about_title_height
        
        infoTable.agora_x = 0
        infoTable.agora_y = titleView.agora_height + LoginConfig.about_title_sep
        infoTable.agora_right = 0
        infoTable.agora_height = LoginConfig.about_cell_height * CGFloat(LoginConfig.AboutInfoList.count)
        
        bottomLabel.agora_bottom = 31
        bottomLabel.agora_center_x = 0
    }
    
}

extension AgoraBaseUIView {
    func addBottomLine() {
        let line = AgoraBaseUIView()
        line.backgroundColor = UIColor(hexString: "EEEEF7")
        
        self.addSubview(line)
        
        line.agora_x = LoginConfig.about_bottom_line_x
        line.agora_width = LoginConfig.about_line_length
        line.agora_height = 1
        line.agora_bottom = 0
    }
}
