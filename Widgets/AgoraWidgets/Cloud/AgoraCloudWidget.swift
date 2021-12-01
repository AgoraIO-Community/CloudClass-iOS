//
//  AgoraCloudWidget.swift
//  AFNetworking
//
//  Created by ZYP on 2021/10/20.
//

import AgoraWidget
import AgoraEduContext
import Masonry

@objcMembers public class AgoraCloudWidget: AgoraBaseWidget {
    private let cloudView = AgoraCloudView(frame: .zero)
    private var vm: AgoraCloudVM!
    
//    public override init(widgetId: String,
//                         properties: [AnyHashable : Any]?) {
//        super.init(widgetId: widgetId,
//                   properties: properties)
//        guard let contextPool = properties?["contextPool"] as? AgoraEduContextPool else {
//            fatalError("can not find contextPool in properties")
//            return
//        }
//        let config = AgoraCloudVM.Config(token: "",
//                                         uid: "1231",
//                                         appId: "",
//                                         hostUrlString: "")
//        self.vm = AgoraCloudVM(contextPool: contextPool,
//                               config: config)
//        setup()
//        initLayout()
//        commonInit()
//    }
    
    private func setup() {
        view.backgroundColor = .clear
        view.addSubview(cloudView)
    }
    
    private func initLayout() {
        cloudView.mas_makeConstraints { make in
            make?.left.equalTo()(self.view)
            make?.right.equalTo()(self.view)
            make?.top.equalTo()(self.view)
            make?.bottom.equalTo()(self.view)
        }
    }
    
    private func commonInit() {
        cloudView.topView.delegate = self
        cloudView.listView.delegate = self
        vm.delegate = self
        vm.start()
    }
    
}

extension AgoraCloudWidget: AgoraCloudTopViewDelegate, AgoraCloudListViewDelegate {
    // MARK: - AgoraCloudTopViewDelegate
    func agoraCloudTopViewDidTapAreaButton(type: AgoraCloudTopView.SelectedType) {
        vm.changeSelectedType(type: type)
        vm.fetchData()
    }
    
    func agoraCloudTopViewDidTapCloseButton() {
        
    }
    
    func agoraCloudTopViewDidTapRefreshButton() {
        vm.fetchData()
    }
    
    // MARK: - AgoraCloudListViewDelegate
    func agoraCloudListViewDidSelectedIndex(index: Int) {
        vm.setSelectedIndex(index: index)
    }
}

extension AgoraCloudWidget: AgoraCloudVMDelegate {
    func agoraCloudVMDidUpdateList(vm: AgoraCloudVM,
                                   list: [AgoraCloudVM.Info]) {
        let viewInfos = list.map({ $0.viewInfo })
        cloudView.listView
            .update(infos: viewInfos)
    }
}

