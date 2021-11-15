//
//  AgoraChatPanelView.swift
//  AgoraEduSDK
//
//  Created by SRS on 2021/1/31.
//

import AgoraUIEduBaseViews.AgoraFiles.AgoraRefresh
import AgoraUIBaseViews
import AgoraEduContext

class AgoraUIChatView: AgoraBaseUIView,
                       UIGestureRecognizerDelegate,
                       UITextFieldDelegate {
    // View
    private(set) lazy var maxView: AgoraChatMaxView = {
        let view = AgoraChatMaxView(frame: .zero)
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor(red: 0.18,
                                         green: 0.25,
                                         blue: 0.57,
                                         alpha: 0.15).cgColor
        view.layer.shadowOffset = CGSize(width: 0,
                                         height: 2)
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 6
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 236.0 / 255.0,
                                         green: 236.0 / 255.0,
                                         blue: 241.0 / 255.0,
                                         alpha: 1).cgColor
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 4
        return view
    }()
    
    private(set) lazy var minView: AgoraChatMinView = {
        let view = AgoraChatMinView(frame: .zero)
        view.backgroundColor = .clear
        return view
    }()
    
    @objc lazy var resignFirstResponderGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(keyboardEndRecognized(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.isEnabled = true
        tapGesture.delegate = self
        return tapGesture
    }()
    
    // MARK: - State
    var showDefaultText = true {
        didSet {
            maxView.chatPlaceHolderView.label.isHidden = !showDefaultText
        }
    }
    
    // 是否是最小化
    var isMin: Bool = true {
        didSet {
            minView.isHidden = !isMin
            maxView.isHidden = isMin
            
            if isMin {
                unreadNum = 0
            }
        }
    }
    
    // 是否有私聊
    var hasConversation: Bool = false {
        didSet {
            if hasConversation {
                maxView.titleViewHasConversation()
            } else {
                maxView.titleViewWithoutConversation()
            }
        }
    }
    
    var unreadNum: Int = 0 {
        didSet {
            let label = minView.label
            label.isHidden = true
            
            guard isMin,
                  unreadNum > 0,
                  let font = minView.label.font else {
                return
            }
            
            let text = (unreadNum > 99 ? "99+" : "\(unreadNum)")
            
            label.isHidden = false
            label.text = "\(text)"
            
            let size = text.agora_size(font: font,
                                       width: CGFloat(MAXFLOAT),
                                       height: label.agora_height)
            
            let textSizeGreaterThanLabelWidth = size.width > label.agora_width
            
            label.agora_width = textSizeGreaterThanLabelWidth ? (size.width + 4) : label.agora_width
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
        initLayout()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        endEditing(true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addFirstResponderGesture() {
        maxView.chatTableView.addGestureRecognizer(self.resignFirstResponderGesture)
    }
    
    func removeFirstResponderGesture() {
        maxView.chatTableView.removeGestureRecognizer(self.resignFirstResponderGesture)
    }
    
    @objc  private func keyboardEndRecognized(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else {
            return
        }
        
        endEditing(true)
    }
}

// MARK: - Rect
private extension AgoraUIChatView {
    func initView() {
        backgroundColor = UIColor.clear
        addSubview(maxView)
        addSubview(minView)
    }
    
    func initLayout() {
        maxView.agora_x = 0
        maxView.agora_y = 0
        maxView.agora_bottom = 0
        maxView.agora_right = 0
        
        minView.agora_x = 0
        minView.agora_y = 0
        minView.agora_right = 0
        minView.agora_bottom = 0
    }
}
