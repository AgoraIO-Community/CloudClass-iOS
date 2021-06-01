//
//  AgoraUserCell.swift
//  AgoraUIEduBaseViews
//
//  Created by LYY on 2021/3/10.
//

import AgoraUIBaseViews
import AgoraEduContext

public protocol AgoraUserCellDelegate: NSObjectProtocol {
    func userCell(_ cell: AgoraUserCell,
                  didPresseVideoMuteAt index: Int)
    func userCell(_ cell: AgoraUserCell,
                  didPresseAudioMuteAt index: Int)
}

public class AgoraUserCell : AgoraBaseUITableViewCell {
    public weak var delegate: AgoraUserCellDelegate?
    public var index = 0
    
    public var info = AgoraEduContextUserDetailInfo(user: AgoraEduContextUserInfo()) {
        didSet {
            let userName = info.user.userName
            nameLabel.text = userName
            nameLabel.agora_width = userName.agoraKitSize(font: .boldSystemFont(ofSize: 13),
                                                          width: 65,
                                                          height: CGFloat(MAXFLOAT)).width
            chatBanImg.image = AgoraKitImage(info.enableChat ? "chat_enable" : "chat_disable")
            updateSpecificCameraState(deviceState: info.cameraState,
                                      coHost: info.coHost,
                                      enableVideo: info.enableVideo,
                                      isSelf: info.isSelf)
            updateSpecificAudioState(deviceState: info.microState,
                                     coHost: info.coHost,
                                     enableAudio: info.enableAudio,
                                     isSelf: info.isSelf)
            
            switch reuseIdentifier {
            case AgoraUserListView.UserCellType.small.rawValue:
                stageImg.image = AgoraKitImage(info.coHost ? "small_onStage" : "small_offStage")
                authImg.image = AgoraKitImage(info.boardGranted ? "boardAuthed" : "boardNotAuthed")
                rewardLabel.text = "x\(info.rewardCount)"
            case AgoraUserListView.UserCellType.big.rawValue:
                bigOnStageImg.agora_x = nameLabel.agora_x + nameLabel.agora_width + 6
                bigOnStageImg.isHidden = !info.coHost
            default:
                break
            }
        }
    }

    private var stageImg: AgoraBaseUIImageView = AgoraBaseUIImageView(frame: .zero)
    private var authImg : AgoraBaseUIImageView = AgoraBaseUIImageView(frame: .zero)
    private var rewardImg : AgoraBaseUIImageView = AgoraBaseUIImageView(image: AgoraKitImage("reward"))
    private var chatBanImg : AgoraBaseUIImageView = AgoraBaseUIImageView(frame: .zero)
    
    private var audioTap: UITapGestureRecognizer?
    private var videoTap: UITapGestureRecognizer?
    
    private func updateSpecificCameraState(deviceState: AgoraEduContextDeviceState,
                                           coHost: Bool,
                                           enableVideo: Bool,
                                           isSelf: Bool) {
        let imgNameStart = "camera"
        var imgNameMid = "_enable"
        var imgNameEnd = "_off"
        
        // 设备关闭或者设备坏的或者不在台上
        if deviceState == .close || deviceState == .notAvailable || !coHost {
            imgNameMid = "_disable"
            imgNameEnd = "_off"
        } else {
            imgNameMid = isSelf ? "_enable" : "_disable"
            imgNameEnd = enableVideo ? "_on" : "_off"
        }
        
        cameraImg.image = AgoraKitImage(imgNameStart + imgNameMid + imgNameEnd)
        
        if let videoTap = self.videoTap,
           isSelf {
            cameraImg.removeGestureRecognizer(videoTap)
            self.videoTap = nil
        }
        
        if imgNameMid == "_enable" && isSelf {
            let tapGesture = UITapGestureRecognizer(target: self,
                                                    action: #selector(onTapVideo))
            tapGesture.numberOfTapsRequired = 1
            cameraImg.addGestureRecognizer(tapGesture)
            self.videoTap = tapGesture
        }
    }
    
    private func updateSpecificAudioState(deviceState: AgoraEduContextDeviceState,
                                          coHost: Bool,
                                          enableAudio: Bool,
                                          isSelf: Bool) {
        let imgNameStart = "micro"
        var imgNameMid = "_enable"
        var imgNameEnd = "_off"
        
        // 设备关闭或者设备坏的或者不在台上
        if deviceState == .close || deviceState == .notAvailable || !coHost {
            imgNameMid = "_disable"
            imgNameEnd = "_off"
        } else {
            imgNameMid = isSelf ? "_enable" : "_disable"
            imgNameEnd = enableAudio ? "_on" : "_off"
        }

        audioImg.image = AgoraKitImage(imgNameStart + imgNameMid + imgNameEnd)
        
        if let audioTap = self.audioTap ,
           isSelf {
            audioImg.removeGestureRecognizer(audioTap)
            self.audioTap = nil
        }
        
        if imgNameMid == "_enable" && isSelf {
            let tapGesture = UITapGestureRecognizer(target: self,
                                                    action: #selector(onTapAudio))
            tapGesture.numberOfTapsRequired = 1
            audioImg.addGestureRecognizer(tapGesture)
            self.audioTap = tapGesture
        }
    }
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        
        switch reuseIdentifier {
        case AgoraUserListView.UserCellType.small.rawValue:
            initMiddleView()
            initMiddleLayout()
        case AgoraUserListView.UserCellType.big.rawValue:
            initBigView()
            initBigLayout()
        default:
            break
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: lazy load
    private lazy var nameLabel: AgoraBaseUILabel = {
        let name = AgoraBaseUILabel()
        name.textColor = UIColor(r: 25,
                                 g: 25,
                                 b: 25)
        name.font = .boldSystemFont(ofSize: 13)
        name.sizeToFit()
        return name
    }()
    
    private lazy var rewardLabel: AgoraBaseUILabel = {
        let label = AgoraBaseUILabel()
        label.sizeToFit()
        label.text = "x0"
        label.textColor = .init(r: 189,
                                g: 189,
                                b: 202)
        label.font = .boldSystemFont(ofSize: 13)
        return label
    }()
    
    private lazy var cameraImg : AgoraBaseUIImageView = {
        let cameraImgView = AgoraBaseUIImageView(image: AgoraKitImage("camera_disable_off"))
        cameraImgView.isUserInteractionEnabled = true
        return cameraImgView
    }()
    
    private var audioImg : AgoraBaseUIImageView = {
        let audioImgView = AgoraBaseUIImageView(image: AgoraKitImage("micro_disable_off"))
        audioImgView.isUserInteractionEnabled = true
        return audioImgView
    }()
    
    private var bigOnStageImg: AgoraBaseUIImageView = {
        let imgView = AgoraBaseUIImageView(image: AgoraKitImage("big_onStage"))
        imgView.isHidden = true
        return imgView
    }()
    
    // MARK: touch event
    func onTapVideo() {
        delegate?.userCell(self,
                           didPresseVideoMuteAt: index)
    }
    
    func onTapAudio() {
        delegate?.userCell(self,
                           didPresseAudioMuteAt: index)
    }
}

// MARK: - UI
private extension AgoraUserCell {
    func initMiddleView() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(stageImg)
        contentView.addSubview(authImg)
        contentView.addSubview(cameraImg)
        contentView.addSubview(audioImg)
        contentView.addSubview(chatBanImg)
        contentView.addSubview(rewardImg)
        contentView.addSubview(rewardLabel)
        selectionStyle = .none
    }
    
    func initMiddleLayout() {
        nameLabel.agora_x = 22
        nameLabel.agora_center_y = 0
        nameLabel.agora_width = 65
        
        stageImg.agora_x = 114
        stageImg.agora_center_y = 0
        stageImg.agora_width = 22
        
        authImg.agora_x = stageImg.agora_x + stageImg.agora_width + 50
        authImg.agora_center_y = 0
        authImg.agora_width = 22
        
        cameraImg.agora_x = authImg.agora_x + authImg.agora_width + 51
        cameraImg.agora_center_y = 0
        cameraImg.agora_width = 22
        
        audioImg.agora_x = cameraImg.agora_x + cameraImg.agora_width + 56
        audioImg.agora_center_y = 0
        audioImg.agora_width = 22
        
        chatBanImg.agora_x = audioImg.agora_x + audioImg.agora_width + 51
        chatBanImg.agora_center_y = 0
        chatBanImg.agora_width = 22
        
        rewardImg.agora_x = chatBanImg.agora_x + chatBanImg.agora_width + 36
        rewardImg.agora_center_y = 0
        rewardImg.agora_width = 22
        
        rewardLabel.agora_x = 494
        rewardLabel.agora_center_y = 0
        rewardLabel.agora_bottom = 11
    }
    
    func initBigView() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(bigOnStageImg)
        contentView.addSubview(cameraImg)
        contentView.addSubview(audioImg)
        contentView.addSubview(chatBanImg)
        selectionStyle = .none
    }
    
    func initBigLayout() {
        nameLabel.agora_x = 22
        nameLabel.agora_center_y = 0
        nameLabel.agora_width = nameLabel.text?.agoraKitSize(font: .boldSystemFont(ofSize: 13),
                                                             width: 65,
                                                             height: CGFloat(MAXFLOAT)).width ?? 65
        
        bigOnStageImg.agora_x = nameLabel.agora_x + nameLabel.agora_width + 6
        bigOnStageImg.agora_center_y = 0

        cameraImg.agora_x = 114
        cameraImg.agora_center_y = 0
        
        audioImg.agora_x = 183
        audioImg.agora_center_y = 0
        
        chatBanImg.agora_x = 245
        chatBanImg.agora_center_y = 0
        
    }
}
