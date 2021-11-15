//
//  AgoraCloudView.swift
//  AgoraWidgets
//
//  Created by ZYP on 2021/10/20.
//

import AgoraUIBaseViews
import AgoraUIEduBaseViews

class AgoraCloudView: AgoraBaseUIView {
    let topView = AgoraCloudTopView(frame: .zero)
    private let headerView = AgoraCloudHeaderView(frame: .zero)
    let listView = AgoraCloudListView(frame: .zero)
    
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
        backgroundColor = .white
        layer.shadowColor = UIColor(rgb: 0x2F4192,
                                    alpha: 0.15).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 1
        layer.shadowRadius = 6
        layer.cornerRadius = 6
        
        addSubview(topView)
        addSubview(headerView)
        addSubview(listView)
    }
    
    private func initLayout() {
        topView.mas_makeConstraints { make in
            make?.left.and().right().and().top().equalTo()(self)
            make?.height.equalTo()(60)
        }
        
        headerView.mas_makeConstraints { make in
            make?.left.and().right().equalTo()(self)
            make?.top.equalTo()(self.topView.mas_bottom)
            make?.height.equalTo()(30)
        }
        
        listView.mas_makeConstraints { make in
            make?.left.and().right().and().bottom().equalTo()(self)
            make?.top.equalTo()(self.headerView.mas_bottom)
        }
    }
    
    private func commonInit() {
        listView.update(infos: [.init(imageName: "",
                                      name: "我的课件.ppt",
                                      sizeString: "1.3 M",
                                      timeString: "2021-09-28 10:31:21")])
    }
    
}


