//
//  AgoraAlertView.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/2/13.
//

import AgoraUIEduBaseViews.AgoraFiles.AgoraAnimatedImage
import AgoraUIBaseViews

@objcMembers public class AgoraAlertImageModel: NSObject {
    public var name: String = ""
    public var width: CGFloat = 0
    public var height: CGFloat = 0
}
@objcMembers public class AgoraAlertLabelModel: NSObject {
    public var text: String = ""
    public var textColor: UIColor = UIColor.clear
    public var textFont: UIFont = UIFont.systemFont(ofSize:12)
}
@objcMembers public class AgoraAlertButtonModel: NSObject {
    public var titleLabel: AgoraAlertLabelModel?
    public var tapActionBlock: ((_ index: Int) -> ())? = nil
}
@objcMembers public class AgoraAlertModel: NSObject {
    public var style: AgoraAlertView.AgoraAlertStyle = .Alert
    public var backgoundColor: UIColor = UIColor.clear
    public var titleLabel: AgoraAlertLabelModel?
    public var titleImage: AgoraAlertImageModel?
    public var messageLabel: AgoraAlertLabelModel?
    public var buttons: [AgoraAlertButtonModel]?
}

@objcMembers public class AgoraAlertView: AgoraBaseUIView {

    public var styleModel: AgoraAlertModel? {
        didSet {
            self.updateView()
        }
    }
    // 0.1
    public var process: Float = 0 {
        didSet {
            if self.styleModel?.style == AgoraAlertView.AgoraAlertStyle.LineLoading {
                let pView = self.lineProgressView.viewWithTag(ProgressTag) as! UIProgressView
                
                if pView.progress >= self.process {
                    return
                }
                
                pView.setProgress(self.process, animated: true)
                
                let pLabel = self.lineProgressView.viewWithTag(LabelTag) as! AgoraBaseUILabel
                pLabel.text = "\(Int(self.process * 100))%"
            }
        }
    }
    
    fileprivate let LabelTag = 99
    fileprivate let ProgressTag = 100
    
    fileprivate lazy var bgView: AgoraBaseUIView =  {
        let v = AgoraBaseUIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        return v
    }()
    
    fileprivate lazy var contentView: AgoraBaseUIView =  {
        let v = AgoraBaseUIView()
        v.layer.backgroundColor = UIColor.white.cgColor
        v.layer.cornerRadius = 20
        v.layer.masksToBounds = true
        v.clipsToBounds = false
        
        v.layer.shadowColor = UIColor(rgb: 0x0E1F2F, alpha: 0.15).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 12
        return v
    }()
    
    fileprivate lazy var titleLabel: AgoraBaseUILabel = {
        let label = AgoraBaseUILabel()
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    fileprivate lazy var cycleView: AgoraCycleView = {
        let v = AgoraCycleView(frame: .zero)
        v.isHidden = true
        return v
    }()
    fileprivate lazy var gifView: AgoraFLAnimatedImageView = {
        
        var animatedImage: AgoraFLAnimatedImage?
        if let bundle = Bundle.agoraUIEduBaseBundle() {
            if let url = bundle.url(forResource: "loading", withExtension: "gif") {
                let imgData = try? Data(contentsOf: url)
                animatedImage = AgoraFLAnimatedImage.init(animatedGIFData: imgData)
            }
        }

        let v = AgoraFLAnimatedImageView()
        v.animatedImage = animatedImage
        v.isHidden = true
        
        return v
    }()

    fileprivate lazy var messageLabel: AgoraBaseUILabel = {
        let label = AgoraBaseUILabel()
        label.textAlignment = .center
        label.isHidden = true
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate lazy var lineProgressView: AgoraBaseUIView =   {
        
        let v = AgoraBaseUIView()
        v.backgroundColor = UIColor.clear
        v.isHidden = true
        
        let label = AgoraBaseUILabel()
        label.text = "0%"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: AgoraKitDeviceAssistant.OS.isPad ? 14 : 12)
        label.textColor = UIColor(rgb: 0x5471FE)
        label.adjustsFontSizeToFitWidth = true
        label.tag = LabelTag
        v.addSubview(label)
        label.agora_y = 0
        label.agora_right = 0
        if AgoraKitDeviceAssistant.OS.isPad {
            label.agora_resize(30, 16)
        } else {
            label.agora_resize(28, 14)
        }
        
        let pView = UIProgressView(progressViewStyle: .bar)
        pView.progressTintColor = UIColor(rgb: 0x5471FE)
        pView.trackTintColor = UIColor(rgb: 0xF0F2F4)
        pView.tag = ProgressTag
        v.addSubview(pView)
        
        pView.translatesAutoresizingMaskIntoConstraints = false
        pView.agora_y = (label.agora_height - pView.frame.size.height) * 0.5
        pView.agora_right = label.agora_right + label.agora_width + 8
        pView.agora_x = 0
        pView.agora_height = pView.frame.size.height
        return v
    }()
    
    fileprivate lazy var btnView: AgoraBaseUIView =   {
        let v = AgoraBaseUIView()
        v.backgroundColor = UIColor.clear
        v.isHidden = true
        return v
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
        self.initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func show(in view: UIView) {
        self.contentView.alpha = 0
        let transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        self.contentView.transform = transform
        
        view.addSubview(self)
        
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.55, delay: 0.2, usingSpringWithDamping: 0.3, initialSpringVelocity: 1.0, options: .curveEaseInOut) {[weak self] in
            self?.contentView.alpha = 1
            self?.contentView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            view.layoutIfNeeded()
        } completion: { (_) in
            
        }
    }
    
    
    // MARK: Touch
    @objc fileprivate func buttonTap(_ btn: AgoraBaseUIButton) {
        guard let btnModels = self.styleModel?.buttons, btn.tag < btnModels.count else {
            return
        }
        
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0
        } completion: { (_) in
            self.removeFromSuperview()
            btnModels[btn.tag].tapActionBlock?(btn.tag)
        }
    }
}

// MARK: Private
extension AgoraAlertView {
    fileprivate func updateView() {
        
        guard let model = self.styleModel else {
            return
        }
    
        self.bgView.backgroundColor = model.backgoundColor
        
        let ratio: CGFloat = 1.2
        
        if model.style == .CircleLoading || model.style == .GifLoading {
            self.contentView.agora_width = AgoraKitDeviceAssistant.OS.isPad ? 120 * ratio : 120
        } else if model.style == .LineLoading {
            self.contentView.agora_width = AgoraKitDeviceAssistant.OS.isPad ? 210 * ratio : 210
        }  else if model.style == .Alert {
            self.contentView.agora_width = AgoraKitDeviceAssistant.OS.isPad ? 270 * ratio : 270
        }
        
        let SideVGap: CGFloat = self.titleLabel.agora_y
        let SideHGap: CGFloat = self.titleLabel.agora_x
        let MessageVGap: CGFloat = AgoraKitDeviceAssistant.OS.isPad ? 18 : 13
        let LoadingViewSize = AgoraKitDeviceAssistant.OS.isPad ? CGSize(width: 60 * ratio, height: 60 * ratio) : CGSize(width: 60, height: 60)

        // titleLabel
        // default value for no title
        var TitleBottom: CGFloat = SideVGap
        self.titleLabel.isHidden = true
        self.cycleView.isHidden = true
        self.gifView.isHidden = true
        
        if model.style == .CircleLoading {
            
            self.cycleView.isHidden = false
            self.cycleView.agora_y = SideVGap
            self.cycleView.agora_center_x = 0
            self.cycleView.agora_resize(model.titleImage?.width ?? LoadingViewSize.width, model.titleImage?.height ?? LoadingViewSize.height)

            self.cycleView.progressTintColor(UIColor(rgb: 0xF0F2F4), to: UIColor(rgb: 0x5471FE))
            self.cycleView.startAnimation()
            
            TitleBottom = self.cycleView.agora_y + self.cycleView.agora_height + MessageVGap
            
        } else if model.style == .GifLoading {
            
            self.gifView.isHidden = false
            
            let gitW = model.titleImage?.width ?? LoadingViewSize.width
            let gitH = model.titleImage?.height ?? LoadingViewSize.height
            let gitX = (self.contentView.agora_width - gitW) * 0.5
            let gitY = SideVGap
            self.gifView.frame = CGRect(x: gitX, y: gitY, width: gitW, height: gitH)
 
            TitleBottom = gitY + gitH
            
        } else if (model.titleImage != nil || model.titleLabel != nil) {
            self.titleLabel.isHidden = false
            var labelHeight: CGFloat = 0
            var textArt: NSAttributedString?
            if let labelModel = model.titleLabel {
                self.titleLabel.font = labelModel.textFont
                self.titleLabel.textColor = labelModel.textColor
                let size = labelModel.text.agoraKitSize(font: labelModel.textFont, height: 25)
                labelHeight = size.height
            
                textArt = NSAttributedString(string: labelModel.text)
            }
            
            let attr = NSMutableAttributedString()
            if let titleImage = model.titleImage {
                
                let imageAttachment = NSTextAttachment()
                let image = AgoraKitImage(titleImage.name)
                imageAttachment.image = image
                imageAttachment.bounds = CGRect(x: 0, y: -4, width: titleImage.width, height: titleImage.height)
                let imgAttr = NSAttributedString(attachment: imageAttachment)
                attr.append(imgAttr)
                
                labelHeight = max(labelHeight, titleImage.height)
            }
            if let art = textArt {
                attr.append(NSAttributedString(string: " "))
                attr.append(art)
            }
            self.titleLabel.attributedText = attr
            
            self.titleLabel.agora_height = labelHeight
            
            TitleBottom = self.titleLabel.agora_y + self.titleLabel.agora_height + MessageVGap
        }
        
        // message
        var MessageBottom: CGFloat = TitleBottom
        self.messageLabel.isHidden = true
        if let messageLabelModel = model.messageLabel {
            self.messageLabel.isHidden = false
            
            self.messageLabel.font = messageLabelModel.textFont
            self.messageLabel.textColor = messageLabelModel.textColor
            self.messageLabel.text = messageLabelModel.text
            
            let size = messageLabelModel.text.agoraKitSize(font: messageLabelModel.textFont,
                                                   width: contentView.agora_width - SideHGap * 2)
            self.messageLabel.agora_y = TitleBottom
            self.messageLabel.agora_height = size.height
            
            MessageBottom = self.messageLabel.agora_y + self.messageLabel.agora_height + MessageVGap
        }
            
        // lineLoading
        var LineLoadingBottom: CGFloat = MessageBottom
        self.lineProgressView.isHidden = true
        if model.style == .LineLoading {
            self.lineProgressView.isHidden = false
            self.lineProgressView.agora_y = MessageBottom

            if (model.buttons?.count ?? 0) > 0 {
                LineLoadingBottom = self.lineProgressView.agora_y + self.lineProgressView.agora_height + MessageVGap
            } else {
                LineLoadingBottom = self.lineProgressView.agora_y + self.lineProgressView.agora_height + SideVGap
            }
        }
        
        // btn & line
        var btnViewBottom: CGFloat = LineLoadingBottom
        self.btnView.isHidden = true
        if let btnModels = model.buttons {
            let btnSubs = self.btnView.subviews
            btnSubs.forEach { (v) in
                v.removeFromSuperview()
            }
            
            self.btnView.isHidden = false
            self.btnView.agora_height = AgoraKitDeviceAssistant.OS.isPad ? 50 : 45
            self.btnView.agora_y = btnViewBottom
            btnViewBottom = LineLoadingBottom + self.btnView.agora_height
        
            // line
            let hLineV = AgoraBaseUIView()
            hLineV.backgroundColor = UIColor(rgb: 0xEDEDED)
            self.btnView.addSubview(hLineV)
            hLineV.agora_move(0, 0)
            hLineV.agora_right = 0
            hLineV.agora_height = 1
            
            // btns
            let btnWidth: CGFloat = self.contentView.agora_width / CGFloat(btnModels.count)
            for (index, btnModel) in btnModels.enumerated() {
                
                let btn = AgoraBaseUIButton(type: .custom)
                btn.tag = index
                btn.addTarget(self, action: #selector(buttonTap(_ :)), for: .touchUpInside)
                self.btnView.addSubview(btn)
                btn.agora_move(CGFloat(index) * btnWidth, hLineV.agora_height)
                btn.agora_width = btnWidth
                btn.agora_bottom = 0
                
                if (index != btnModels.count - 1) {
                    let vLineV = AgoraBaseUIView()
                    vLineV.backgroundColor = UIColor(rgb: 0xEDEDED)
                    self.btnView.addSubview(vLineV)
                    vLineV.agora_move(btn.agora_x + btn.agora_width - 1, 0)
                    vLineV.agora_width = 1
                    vLineV.agora_bottom = 0
                }
                
                if let btnTitleLabelModle = btnModel.titleLabel {
                    btn.setTitle(btnTitleLabelModle.text, for: .normal)
                    btn.setTitleColor(btnTitleLabelModle.textColor, for: .normal)
                    btn.titleLabel?.font = btnTitleLabelModle.textFont
                } else {
                    continue
                }
            }
        }
        
        if model.style == .CircleLoading || model.style == .GifLoading {
            self.contentView.agora_height =  self.contentView.agora_width
        } else {
            self.contentView.agora_height = btnViewBottom
        }
    }
}

// MARK: Private--Init
extension AgoraAlertView {
    fileprivate func initView() {
        backgroundColor = .clear

        self.addSubview(self.bgView)
        self.addSubview(self.contentView)

        self.contentView.addSubview(self.cycleView)
        self.contentView.addSubview(self.gifView)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.messageLabel)
        self.contentView.addSubview(self.lineProgressView)
        self.contentView.addSubview(self.btnView)
    }
    
    fileprivate func initLayout() {
        self.bgView.agora_move(0, 0)
        self.bgView.agora_right = 0
        self.bgView.agora_bottom = 0
        
        self.contentView.agora_center_x = 0
        self.contentView.agora_center_y = -30
        self.contentView.agora_width = 1000
        self.contentView.agora_height = 1000
        
        let SideVGap: CGFloat = 25
        let SideHGap: CGFloat = 10
        let LineProgressHGap: CGFloat = 28

        self.titleLabel.agora_x = SideHGap
        self.titleLabel.agora_y = SideVGap
        self.titleLabel.agora_height = 0
        self.titleLabel.agora_right = SideHGap

        self.messageLabel.agora_x = SideHGap
        self.messageLabel.agora_right = SideHGap
        self.messageLabel.agora_y = 0
        self.messageLabel.agora_height = 0

        let label = self.lineProgressView.viewWithTag(LabelTag) as! AgoraBaseUILabel
        self.lineProgressView.agora_x = LineProgressHGap
        self.lineProgressView.agora_right = LineProgressHGap
        self.lineProgressView.agora_y = 0
        self.lineProgressView.agora_height = label.agora_height

        self.btnView.agora_x = 0
        self.btnView.agora_right = 0
        self.btnView.agora_height = 0
        self.btnView.agora_y = 0
    }
}

extension AgoraAlertView {
    @objc public enum AgoraAlertStyle: Int {
        /// UI类型：`加载`
        case CircleLoading
        /// UI类型：`加载`
        case GifLoading
        /// UI类型: `加载`
        case LineLoading
        /// UI类型：`有点击按钮的alert`
        case Alert
    }
}
