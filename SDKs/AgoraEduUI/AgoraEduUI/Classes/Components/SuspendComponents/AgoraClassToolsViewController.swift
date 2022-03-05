//
//  AgoraClassToolsViewController.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/3/5.
//

import AgoraEduContext
import AgoraWidget
import UIKit

class AgoraClassToolsViewController: UIViewController {
    private let answerSelectorId = "AnswerSelector"
    
    private var answerSelector: AgoraBaseWidget?
    
    private var contextPool: AgoraEduContextPool!
    
    init(context: AgoraEduContextPool) {
        self.contextPool = context
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let widget = contextPool.widget
        widget.add(self)
    }
}

private extension AgoraClassToolsViewController {
    func createAnswerSelector() {
        let widget = contextPool.widget
        
        guard let config = widget.getWidgetConfig(answerSelectorId) else {
            return
        }
        
        let answerSelector = widget.create(config)
        view.addSubview(answerSelector.view)
        answerSelector.view.backgroundColor = .red
        
        answerSelector.view.frame = CGRect(x: 100,
                                           y: 100,
                                           width: 240,
                                           height: 208)
        
//        answerSelector.view.agora_x = 100
//        answerSelector.view.agora_y = 100
//        answerSelector.view.agora_width = 240
//        answerSelector.view.agora_height = 208
        
        self.answerSelector = answerSelector
    }
}

extension AgoraClassToolsViewController: AgoraWidgetActivityObserver {
    func onWidgetActive(_ widgetId: String) {
        
    }
    
    func onWidgetInactive(_ widgetId: String) {
        
    }
}
