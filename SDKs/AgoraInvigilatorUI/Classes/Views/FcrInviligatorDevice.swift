//
//  FcrInviligatorDevice.swift
//  AgoraInvigilatorUI
//
//  Created by DoubleCircle on 2022/9/4.
//

import AgoraUIBaseViews

class FcrInviligatorDevice: UIView {
    private(set) lazy var exitButton = UIButton()
    private(set) lazy var titleLabel = UILabel()
    private(set) lazy var nameLabel = UILabel()
    private(set) lazy var stateLabel = UILabel()
    private(set) lazy var enterButton = UIButton()
    
    convenience init(renderView: FcrInviligatorRenderView) {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - AgoraUIContentContainer
extension FcrInviligatorDevice: AgoraUIContentContainer {
    func initViews() {
        
    }
    
    func initViewFrame() {
        
    }
    
    func updateViewProperties() {
        
    }
}
