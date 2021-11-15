//
//  AgoraCloudTopBarView.swift
//  AgoraWidgets
//
//  Created by ZYP on 2021/10/20.
//

import AgoraUIBaseViews
import AgoraUIEduBaseViews
import Masonry

protocol AgoraCloudTopViewDelegate: NSObjectProtocol {
    func agoraCloudTopViewDidTapAreaButton(type: AgoraCloudTopView.SelectedType)
    func agoraCloudTopViewDidTapCloseButton()
    func agoraCloudTopViewDidTapRefreshButton()
}

class AgoraCloudTopView: AgoraBaseUIView {
    private let contentView1 = AgoraBaseUIView()
    private let publicAreaButton = AgoraBaseUIButton()
    private let privateAreaButton = AgoraBaseUIButton()
//    private let closeButton = AgoraBaseUIButton()
    private let publicAreaIndicatedView = AgoraBaseUIView()
    private let privateAreaIndicatedView = AgoraBaseUIView()
    private let lineView1 = AgoraBaseUIView()
    
    private let contentView2 = AgoraBaseUIView()
    private let refreshButton = AgoraBaseUIButton()
    private let pathNameLabel = AgoraBaseUILabel()
    private let fileCountLabel = AgoraBaseUILabel()
    private let lineView2 = AgoraBaseUIView()
    
    private var selectedType: SelectedType = .selectedPublic
    private var fileNum = 0
    weak var delegate: AgoraCloudTopViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        initLayout()
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        /// 上半部分
        contentView1.backgroundColor = UIColor(rgb: 0xF9F9FC)
        let buttonNormalColor = UIColor(rgb: 0x586376)
        let buttonSelectedColor = UIColor(rgb: 0x191919)
        let indicateViewColor = UIColor(rgb: 0x0073FF)
        let lineColor = UIColor(rgb: 0xEEEEF7)
        
        publicAreaButton.setTitle("公共资源",
                                  for: .normal)
        publicAreaButton.setTitle("公共资源",
                                  for: .selected)
        publicAreaButton.titleLabel?.font = .systemFont(ofSize: 12)
        publicAreaButton.setTitleColor(buttonNormalColor,
                                       for: .normal)
        publicAreaButton.setTitleColor(buttonSelectedColor,
                                       for: .selected)
        
        privateAreaButton.setTitle("我的云盘",
                                   for: .normal)
        privateAreaButton.setTitle("我的云盘",
                                   for: .selected)
        privateAreaButton.titleLabel?.font = .systemFont(ofSize: 12)
        privateAreaButton.setTitleColor(buttonNormalColor,
                                        for: .normal)
        privateAreaButton.setTitleColor(buttonSelectedColor,
                                        for: .selected)
        
        publicAreaIndicatedView.backgroundColor = indicateViewColor
        publicAreaIndicatedView.isHidden = true
        privateAreaIndicatedView.backgroundColor = indicateViewColor
        privateAreaIndicatedView.isHidden = true
        
        let closeImage = GetWidgetImage(object: self,
                                        "icon_close")
//        closeButton.setImage(closeImage,
//                             for: .normal)
        
        lineView1.backgroundColor = lineColor
        
        addSubview(contentView1)
        contentView1.addSubview(publicAreaButton)
        contentView1.addSubview(privateAreaButton)
//        contentView1.addSubview(closeButton)
        contentView1.addSubview(lineView1)
        contentView1.addSubview(publicAreaIndicatedView)
        contentView1.addSubview(privateAreaIndicatedView)
        
        /// 下半部分
        contentView2.backgroundColor = .white
        let refreshImage = GetWidgetImage(object: self,
                                          "icon_refresh")
        let textColor = UIColor(rgb: 0x191919)
        
        refreshButton.setImage(refreshImage,
                               for: .normal)
        
        pathNameLabel.textColor = textColor
        pathNameLabel.font = .systemFont(ofSize: 12)
        pathNameLabel.textAlignment = .left
        
        fileCountLabel.textColor = textColor
        fileCountLabel.font = .systemFont(ofSize: 12)
        fileCountLabel.textAlignment = .right
        
        lineView2.backgroundColor = lineColor
        
        addSubview(contentView2)
        contentView2.addSubview(refreshButton)
        contentView2.addSubview(pathNameLabel)
        contentView2.addSubview(fileCountLabel)
        contentView2.addSubview(lineView2)
    }
    
    private func commonInit() {
        publicAreaButton.addTarget(self,
                                   action: #selector(buttonTap(sender:)),
                                   for: .touchUpInside)
        privateAreaButton.addTarget(self,
                                    action: #selector(buttonTap(sender:)),
                                    for: .touchUpInside)
//        closeButton.addTarget(self,
//                              action: #selector(buttonTap(sender:)),
//                              for: .touchUpInside)
        refreshButton.addTarget(self,
                                action: #selector(buttonTap(sender:)),
                                for: .touchUpInside)
        
        config(selectedType: .selectedPublic)
    }
    
    private func initLayout() {
        /// 上半部分
        contentView1.mas_makeConstraints { make in
            make?.left.equalTo()(self.mas_left)
            make?.right.equalTo()(self.mas_right)
            make?.top.equalTo()(self.mas_top)
            make?.height.equalTo()(30)
        }
        
        publicAreaButton.mas_makeConstraints { make in
            make?.centerY.equalTo()(self.contentView1)
            make?.left.equalTo()(24)
            make?.width.equalTo()(80)
        }
        
        privateAreaButton.mas_makeConstraints { make in
            make?.centerY.equalTo()(self.contentView1)
            make?.left.equalTo()(publicAreaButton.mas_right)
            make?.width.equalTo()(80)
        }
        
        publicAreaIndicatedView.mas_makeConstraints { make in
            make?.width.equalTo()(66)
            make?.height.equalTo()(2)
            make?.bottom.equalTo()(self.contentView1)
            make?.centerX.equalTo()(publicAreaButton.mas_centerX)
        }
        privateAreaIndicatedView.mas_makeConstraints { make in
            make?.width.equalTo()(66)
            make?.height.equalTo()(2)
            make?.bottom.equalTo()(self.contentView1)
            make?.centerX.equalTo()(privateAreaButton.mas_centerX)
        }
        
//        closeButton.mas_makeConstraints { make in
//            make?.centerY.equalTo()(self.contentView1)
//            make?.width.equalTo()(24)
//            make?.height.equalTo()(24)
//            make?.right.equalTo()(self.contentView1.mas_right)?.offset()(-10)
//        }
        
        lineView1.mas_makeConstraints { make in
            make?.left.equalTo()(self.contentView1)
            make?.right.equalTo()(self.contentView1)
            make?.bottom.equalTo()(self.contentView1)
            make?.height.equalTo()(1)
        }
        
        /// 下半部分
        contentView2.mas_makeConstraints { make in
            make?.left.equalTo()(self.mas_left)
            make?.right.equalTo()(self.mas_right)
            make?.bottom.equalTo()(self.mas_bottom)
            make?.height.equalTo()(30)
        }
        
        refreshButton.mas_makeConstraints { make in
            make?.centerY.equalTo()(self.contentView2)
            make?.left.equalTo()(self.contentView2)?.offset()(21)
            make?.height.equalTo()(26)
            make?.width.equalTo()(26)
        }
        
        pathNameLabel.mas_makeConstraints { make in
            make?.left.equalTo()(refreshButton.mas_right)?.offset()(10)
            make?.centerY.equalTo()(self.contentView2)
        }
        
        fileCountLabel.mas_makeConstraints { make in
            make?.right.equalTo()(self.contentView2)?.offset()(-10)
            make?.centerY.equalTo()(self.contentView2)
        }
        
        lineView2.mas_makeConstraints { make in
            make?.left.equalTo()(self.contentView2)
            make?.right.equalTo()(self.contentView2)
            make?.bottom.equalTo()(self.contentView2)
            make?.height.equalTo()(1)
        }
    }
    
    @objc func buttonTap(sender: UIButton) {
//        if sender == closeButton {
//            delegate?.agoraCloudTopViewDidTapCloseButton()
//            return
//        }
        
        if sender == publicAreaButton {
            config(selectedType: .selectedPublic)
            delegate?.agoraCloudTopViewDidTapAreaButton(type: .selectedPublic)
            return
        }
        
        if sender == privateAreaButton {
            config(selectedType: .selectedPrivate)
            delegate?.agoraCloudTopViewDidTapAreaButton(type: .selectedPrivate)
            return
        }
        
        if sender == refreshButton {
            delegate?.agoraCloudTopViewDidTapRefreshButton()
            return
        }
    }
    
    private func config(selectedType: SelectedType) {
        self.selectedType = selectedType
        switch selectedType {
        case .selectedPublic:
            privateAreaButton.isSelected = false
            publicAreaButton.isSelected = true
            privateAreaIndicatedView.isHidden = true
            publicAreaIndicatedView.isHidden = false
            break
        case .selectedPrivate:
            publicAreaButton.isSelected = false
            privateAreaButton.isSelected = true
            publicAreaIndicatedView.isHidden = true
            privateAreaIndicatedView.isHidden = false
            break
        }
        pathNameLabel.text = selectedType == .selectedPublic ? "公共资源 > 课件" : "我的云盘 > 课件"
    }
    
    func set(fileNum: Int) {
        fileCountLabel.text = "共\(fileNum)项"
    }
    
    var currentSelectedType: SelectedType {
        return selectedType
    }
}

extension AgoraCloudTopView {
    enum SelectedType {
        /// 公共资源
        case selectedPublic
        /// 我的云盘
        case selectedPrivate
    }
}
