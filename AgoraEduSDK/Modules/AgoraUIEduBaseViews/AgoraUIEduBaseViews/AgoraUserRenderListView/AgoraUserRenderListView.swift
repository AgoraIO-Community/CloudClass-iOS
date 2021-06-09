//
//  AgoraUserRenderListView.swift
//  AgoraUIEduBaseViews
//
//  Created by ZYP on 2021/3/12.
//

import UIKit
import AgoraUIBaseViews
import AgoraEduContext

@objcMembers public class AgoraUserRenderListView: AgoraBaseUIView {
    public static let preferenceHeight: CGFloat = AgoraKitDeviceAssistant.OS.isPad ? 168 : 87
    
    public weak var context: AgoraEduUserContext?
    
    public let leftButton = AgoraBaseUIButton()
    public let rightButton = AgoraBaseUIButton()
    
    public let collectionView = AgoraBaseUICollectionView(frame: .zero,
                                                          collectionViewLayout: UICollectionViewFlowLayout())
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
        initLayout()
        observeUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
        initLayout()
        observeUI()
    }
    
    // MARK: touch event
    @objc func buttonTap(btn: AgoraBaseUIButton) {
        let width = collectionView.bounds.width
        let height = collectionView.bounds.height
        var x: CGFloat = 0
        
        if btn == leftButton {
            x = collectionView.contentOffset.x - width
            x = max(x,
                    0)
        } else {
            x = collectionView.contentOffset.x + width
            x = min(x,
                    collectionView.contentSize.width)
        }
        
        collectionView.scrollRectToVisible(CGRect(x: x,
                                                  y: 0,
                                                  width: width,
                                                  height: height),
                                           animated: true)
    }
}

// MARK: - Private
private extension AgoraUserRenderListView {
    func initViews() {
        clipsToBounds = true
        layer.cornerRadius = AgoraKitDeviceAssistant.OS.isPad ? 10 : 4
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: AgoraUserRenderListView.preferenceHeight,
                                     height: AgoraUserRenderListView.preferenceHeight)

        flowLayout.minimumLineSpacing = 2
        flowLayout.scrollDirection = .horizontal
        collectionView.setCollectionViewLayout(flowLayout,
                                               animated: false)
        collectionView.backgroundColor = UIColor(rgb: 0xf8f8fc)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(AgoraUserRenderCell.self,
                                forCellWithReuseIdentifier: "AgoraUserRenderCell")
        
        leftButton.setTitle(nil,
                            for: .normal)
        leftButton.setImage(AgoraKitImage("leftButtonIcon"),
                            for: .normal)
        leftButton.isHidden = true
        
        rightButton.setTitle(nil,
                             for: .normal)
        rightButton.setImage(AgoraKitImage("rightButtonIcon"),
                             for: .normal)
        rightButton.isHidden = true

        addSubview(collectionView)
        addSubview(leftButton)
        addSubview(rightButton)
    }
    
    func initLayout() {
        collectionView.agora_x = 0
        collectionView.agora_y = 0
        collectionView.agora_right = 0
        collectionView.agora_bottom = 0
        
        leftButton.agora_x = 0
        leftButton.agora_y = 0
        leftButton.agora_bottom = 0
        
        rightButton.agora_right = 0
        rightButton.agora_y = 0
        rightButton.agora_bottom = 0
    }
    
    func observeUI() {
        leftButton.addTarget(self,
                             action: #selector(buttonTap(btn:)),
                             for: .touchUpInside)
        rightButton.addTarget(self,
                              action: #selector(buttonTap(btn:)),
                              for: .touchUpInside)
    }
}
