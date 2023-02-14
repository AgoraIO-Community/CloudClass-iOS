//
//  FcrWatermarkUIComponent.swift
//  AgoraEduUI
//
//  Created by Cavan on 2023/2/13.
//

import AgoraEduCore
import AgoraWidget

class FcrWatermarkUIComponent: UIViewController {
    private let widgetController: AgoraEduWidgetContext
    private var widget: AgoraBaseWidget?
    
    init(widgetController: AgoraEduWidgetContext) {
        self.widgetController = widgetController
        
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = AgoraBaseUIContainer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let config = widgetController.getWidgetConfig(WatermarkWidgetId) else {
            view.isHidden = true
            return
        }
        
        let widget = widgetController.create(config)
        
        view.addSubview(widget.view)
        
        widget.view.mas_makeConstraints { make in
            make?.top.bottom().left().right().equalTo()(self.view)
        }
        
        self.widget = widget
    }
}
