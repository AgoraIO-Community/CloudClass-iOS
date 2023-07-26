//
//  FcrNetworkStatsUIComponent.swift
//  AgoraEduUI
//
//  Created by Cavan on 2023/7/24.
//

import AgoraUIBaseViews
import AgoraEduCore

class FcrNetworkStatsUIComponent: FcrUIComponent, AgoraUIContentContainer {
    private let titleLabel = UILabel()
    private let lineView = UIView()
    private let latencyTitleLabel = UILabel()
    private let latencyValueLabel = UILabel()
    
    private let packetLossRateTitleLabel = UILabel()
    private let packetLossRateTxImageView = UIImageView()
    private let packetLossRateRxImageView = UIImageView()
    private let packetLossRateTxLabel = UILabel()
    private let packetLossRateRxLabel = UILabel()
    
    private var monitor: AgoraEduMonitorContext
    
    init(monitorController: AgoraEduMonitorContext) {
        self.monitor = monitorController
        
        super.init(nibName: nil,
                   bundle: nil)
        
        monitorController.registerMonitorEventHandler(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        initViewFrame()
        updateViewProperties()
    }
    
    func initViews() {
        view.addSubview(titleLabel)
        view.addSubview(lineView)
        
        view.addSubview(latencyTitleLabel)
        view.addSubview(latencyValueLabel)
        
        view.addSubview(packetLossRateTitleLabel)
        view.addSubview(packetLossRateTxImageView)
        view.addSubview(packetLossRateRxImageView)
        view.addSubview(packetLossRateTxLabel)
        view.addSubview(packetLossRateRxLabel)
        
        titleLabel.textAlignment = .center
        
        packetLossRateTxLabel.text = "--"
        packetLossRateRxLabel.text = "--"
        
        updateTitleLabel(with: .good)
    }
    
    func initViewFrame() {
        titleLabel.mas_makeConstraints { make in
            make?.top.equalTo()(12)
            make?.left.right().equalTo()(0)
            make?.height.equalTo()(12)
        }
        
        lineView.mas_makeConstraints { make in
            make?.top.equalTo()(36)
            make?.left.right().equalTo()(0)
            make?.height.equalTo()(1)
        }
        
        latencyTitleLabel.mas_makeConstraints { make in
            make?.left.equalTo()(10)
            make?.top.equalTo()(lineView.mas_bottom)?.offset()(12)
            make?.height.equalTo()(12)
            make?.width.equalTo()(100)
        }
        
        latencyValueLabel.mas_makeConstraints { make in
            make?.left.equalTo()(63)
            make?.top.equalTo()(lineView.mas_bottom)?.offset()(12)
            make?.height.equalTo()(12)
            make?.right.equalTo()(0)
        }
        
        packetLossRateTitleLabel.mas_makeConstraints { make in
            make?.left.equalTo()(10)
            make?.top.equalTo()(latencyTitleLabel.mas_bottom)?.offset()(18)
            make?.height.equalTo()(12)
            make?.width.equalTo()(50)
        }
        
        packetLossRateTxImageView.mas_makeConstraints { make in
            make?.left.equalTo()(63)
            make?.top.equalTo()(latencyTitleLabel.mas_bottom)?.offset()(18)
            make?.height.equalTo()(18)
            make?.width.equalTo()(18)
        }
        
        packetLossRateRxImageView.mas_makeConstraints { make in
            make?.left.equalTo()(63)
            make?.top.equalTo()(packetLossRateTxImageView.mas_bottom)?.offset()(10)
            make?.height.equalTo()(18)
            make?.width.equalTo()(18)
        }
        
        packetLossRateTxLabel.mas_makeConstraints { make in
            make?.left.equalTo()(packetLossRateTxImageView.mas_right)?.offset()(7)
            make?.top.equalTo()(latencyTitleLabel.mas_bottom)?.offset()(18)
            make?.height.equalTo()(18)
            make?.right.equalTo()(0)
        }
        
        packetLossRateRxLabel.mas_makeConstraints { make in
            make?.left.equalTo()(packetLossRateTxImageView.mas_right)?.offset()(7)
            make?.top.equalTo()(packetLossRateTxImageView.mas_bottom)?.offset()(10)
            make?.height.equalTo()(18)
            make?.right.equalTo()(0)
        }
    }
    
    func updateViewProperties() {
        let config = UIConfig.networkStats
        
        titleLabel.font = config.title.font
        
        lineView.backgroundColor = config.sepLine.backgroundColor
        
        latencyTitleLabel.text = "fcr_network_label_network_latency".edu_ui_localized()
        latencyTitleLabel.font = config.latencyTitle.font
        latencyTitleLabel.textColor = config.latencyTitle.textColor
        
        latencyValueLabel.font = config.latencyValue.font
        latencyValueLabel.textColor = config.latencyValue.textColor
        
        packetLossRateTitleLabel.text = "fcr_network_label_network_packet_loss_rate".edu_ui_localized()
        packetLossRateTitleLabel.font = config.packetLossRateTitle.font
        packetLossRateTitleLabel.textColor = config.packetLossRateTitle.textColor
        
        packetLossRateTxImageView.image = config.packetLossRateValue.txImage
        packetLossRateRxImageView.image = config.packetLossRateValue.rxImage
        
        packetLossRateTxLabel.font = config.packetLossRateValue.font
        packetLossRateRxLabel.font = config.packetLossRateValue.font
        
        packetLossRateTxLabel.textColor = config.packetLossRateValue.textColor
        packetLossRateRxLabel.textColor = config.packetLossRateValue.textColor
    }
    
    private func updateTitleLabel(with quality: AgoraEduContextNetworkQuality) {
        let config = UIConfig.networkStats.title
        
        var text: String
        var color: UIColor
        
        switch quality {
        case .good:
            text = "fcr_network_label_network_quality_excellent".edu_ui_localized()
            color = config.goodColor
        case .bad:
            text = "fcr_network_label_network_quality_bad".edu_ui_localized()
            color = config.badColor
        case .down:
            text = "fcr_network_label_network_quality_down".edu_ui_localized()
            color = config.downColor
        default:
            return
        }
        
        titleLabel.textColor = color
        titleLabel.text = text
    }
}

extension FcrNetworkStatsUIComponent: AgoraEduMonitorHandler {
    func onLocalConnectionUpdated(state: AgoraEduContextConnectionState) {
        guard state == .disconnected || state == .reconnecting else {
            return
        }
        
        updateTitleLabel(with: .down)
    }
    
    func onLocalNetworkQualityUpdated(quality: AgoraEduContextNetworkQuality) {
        updateTitleLabel(with: quality)
    }
    
    func onMediaPacketStatsUpdated(roomUuid: String,
                                   stats: FcrMediaPacketStats) {
        latencyValueLabel.text = "\(stats.lastMileDelay)ms"
        packetLossRateTxLabel.text = "\(stats.txPacketLossRate)%"
        packetLossRateRxLabel.text = "\(stats.rxPacketLossRate)%"
    }
}
