//
//  DebugView.swift
//  AgoraEducation
//
//  Created by LYY on 2022/8/5.
//  Copyright © 2022 Agora. All rights reserved.
//

import AgoraUIBaseViews

protocol DebugViewDelagate: NSObjectProtocol {
    func didClickClose()
    func didClickEnter()
}

class DebugView: UIView {
    /**data**/
    weak var delegate: DebugViewDelagate?
    /**views**/
    // title
    private lazy var titleLabel = UILabel()
    // only ipad
    private lazy var subTitleLabel = UILabel()
    // only iphone
    private lazy var topImageView = AgoraBaseUIImageView(frame: .zero)
    // logo
    private lazy var logoImageView = UIImageView(frame: .zero)
    // close debug view
    private lazy var closeButton = UIButton(frame: .zero)
    // enter classroom
    private lazy var enterButton = UIButton(frame: .zero)
    // bottom info
    private lazy var bottomLabel = UILabel(frame: .zero)
    // info list
    private(set) lazy var tableView = UITableView(frame: .zero,
                                             style: .plain)
    private(set) lazy var optionsView = DebugOptionsView(frame: .zero)
}
