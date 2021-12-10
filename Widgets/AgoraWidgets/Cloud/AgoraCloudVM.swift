//
//  AgoraCloudVM.swift
//  AgoraWidgets
//
//  Created by ZYP on 2021/10/23.
//

import AgoraWidget
import AgoraEduContext

protocol AgoraCloudVMDelegate: NSObjectProtocol {
    func agoraCloudVMDidUpdateList(vm: AgoraCloudVM,
                                   list: [AgoraCloudVM.Info])
}

class AgoraCloudVM: NSObject {
    private var publicFiles = [Info]()
    private var privateFiles = [Info]()
    private var serverApi: CloudServerApi!
    private let contextPool: AgoraEduContextPool!
    private var selectedType: SelectedType = .selectedPublic
    weak var delegate: AgoraCloudVMDelegate?
    private var currentPageNo = 0
    private var currentRequestingPageNo: Int?
    
    init(contextPool: AgoraEduContextPool,
         config: Config) {
        // TODO: 获取白板课件？
//        self.publicFiles = contextPool.whiteBoard.getCoursewares().map({ Info(courseware: $0) })
        self.contextPool = contextPool
        self.serverApi = CloudServerApi(config: config)
        super.init()
    }
    
    func start() {
        fetchPrivate()
    }
    
    func fetchData() {
        switch selectedType {
        case .selectedPublic:
            break
        case .selectedPrivate:
            fetchPrivate()
            break
        }
    }
    
    /// 获取个人数据
    private func fetchPrivate() {
        guard currentRequestingPageNo == nil else {
            return
        }
        let pageNo = currentPageNo
        currentPageNo = pageNo
        serverApi.requestResourceInUser(pageNo: pageNo,
                                        pageSize: 300) { [weak self](resp) in
            self?.currentRequestingPageNo = nil
            guard let `self` = self else { return }
            self.currentPageNo += 1
            var temp = self.privateFiles
            let list = resp.data.list.map({ Info(fileItem: $0) })
            for item in list {
                if !(temp.contains(item)) {
                    temp.append(item)
                }
            }
            self.privateFiles = temp
            self.changeSelectedType(type: self.selectedType)
        } fail: { [weak self](error) in
            print(error)
            self?.currentRequestingPageNo = nil
        }
    }
    
    func checkShouldFetchData(currentRow: Int) {
        guard selectedType == .selectedPrivate else {
            return
        }
        
        let currentMaxRow = (currentPageNo + 1) * 300 - 1
        fetchData()
    }
    
    func setSelectedIndex(index: Int) {
        let dataList = selectedType == .selectedPublic ? publicFiles : privateFiles
        let info = dataList[index]
        let dir = info.courseware.scenePath
        // TODO: 白板widget能力
//        contextPool.whiteBoard.pushScenes(dir: dir,
//                                          scenes: info.courseware.scenes,
//                                          index: 1)
    }
    
    func changeSelectedType(type: SelectedType) {
        self.selectedType = type
        let list = type == .selectedPublic ? publicFiles : privateFiles
        delegate?.agoraCloudVMDidUpdateList(vm: self,
                                            list: list)
    }
}




