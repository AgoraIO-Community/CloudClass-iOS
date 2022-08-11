//
//  FcrBoardPageControlView.swift
//  AgoraEduUI
//
//  Created by LYY on 2022/7/11.
//

import AgoraUIBaseViews

class FcrBoardPageControlView: UIView {
    /** Views*/
    private lazy var sepLine: UIView = UIView(frame: .zero)
    private let pageLabel: UILabel = UILabel(frame: .zero)
    
    lazy var addBtn: UIButton = UIButton(type: .custom)
    lazy var prevBtn: UIButton = UIButton(type: .custom)
    lazy var nextBtn: UIButton = UIButton(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updatePage(_ index: Int, pages: Int) {
        pageLabel.text = "\(index) / \(pages)"
        prevBtn.isEnabled = (index > 1)
        nextBtn.isEnabled = (index < pages)
    }
}

extension FcrBoardPageControlView: AgoraUIContentContainer {
    func initViews() {
        addSubview(addBtn)
        addSubview(sepLine)
        addSubview(prevBtn)
        
        pageLabel.text = "1 / 1"
        pageLabel.textAlignment = .center
        addSubview(pageLabel)
        
        addSubview(nextBtn)
    }
    
    func initViewFrame() {
        let kButtonWidth = 30
        let kButtonHeight = 30
        addBtn.mas_remakeConstraints { make in
            make?.centerY.equalTo()(self)
            make?.left.equalTo()(10)
            make?.width.height().equalTo()(kButtonWidth)
        }
        
        sepLine.mas_makeConstraints { make in
            make?.centerY.equalTo()(self)
            make?.left.equalTo()(self.addBtn.mas_right)?.offset()(4)
            make?.top.equalTo()(8)
            make?.bottom.equalTo()(-8)
            make?.width.equalTo()(1)
        }

        prevBtn.mas_remakeConstraints { make in
            make?.centerY.equalTo()(self)
            make?.left.equalTo()(self.sepLine.mas_right)?.offset()(3)
            make?.width.height().equalTo()(kButtonWidth)
        }
        
        nextBtn.mas_makeConstraints { make in
            make?.centerY.equalTo()(self)
            make?.right.equalTo()(-10)
            make?.width.height().equalTo()(kButtonWidth)
        }
        
        pageLabel.mas_makeConstraints { make in
            make?.centerY.equalTo()(self)
            make?.left.equalTo()(self.prevBtn.mas_right)?.offset()(0)
            make?.right.equalTo()(self.nextBtn.mas_left)?.offset()(0)
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.netlessBoard.pageControl
        
        addBtn.setImage(config.addPageImage,
                        for: .normal)
        prevBtn.setImage(config.prevPageImage,
                         for: .normal)
        prevBtn.setImage(config.disabledPrevPageImage,
                         for: .disabled)
        nextBtn.setImage(config.nextPageImage,
                         for: .normal)
        nextBtn.setImage(config.disabledNextPageImage,
                         for: .disabled)
        
        backgroundColor = config.backgroundColor
        layer.cornerRadius = config.cornerRadius
        
        layer.shadowColor = config.shadow.color
        layer.shadowOffset = config.shadow.offset
        layer.shadowOpacity = config.shadow.opacity
        layer.shadowRadius = config.shadow.radius

        sepLine.backgroundColor = config.sepLine.backgroundColor

        pageLabel.font = config.pageLabel.font
        pageLabel.textColor = config.pageLabel.color
    }
}
