//
//  AgoraRenderMicView.swift
//  AgoraEduUI
//
//  Created by Jonathan on 2021/12/8.
//

import UIKit

class AgoraRenderMicView: UIView {
    
    enum AgoraRenderMicViewState {
        case on, off, forbidden
    }
    
    private var imageView: UIImageView!
    
    private var animaView: UIImageView!
    
    private var micState: AgoraRenderMicViewState = .off
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setVolume(_ value: Int) {
        guard micState == .on else {
            return
        }
        animaView.isHidden = value > 30
    }
    
    public func setState(_ state: AgoraRenderMicViewState) {
        guard micState != state else {
            return
        }
        micState = state
        switch state {
        case .on:
            imageView.image = UIImage.ag_imageNamed("ic_mic_status_on",
                                                    in: "AgoraEduUI")
            animaView.isHidden = false
        case .off:
            imageView.image = UIImage.ag_imageNamed("ic_mic_status_off",
                                                    in: "AgoraEduUI")
            animaView.isHidden = true
        case .forbidden:
            imageView.image = UIImage.ag_imageNamed("ic_mic_status_forbidden",
                                                    in: "AgoraEduUI")
            animaView.isHidden = true
        }
    }
}

private extension AgoraRenderMicView {
    func createViews() {
        imageView = UIImageView()
        imageView.image = UIImage.ag_imageNamed("ic_mic_status_off",
                                                in: "AgoraEduUI")
        addSubview(imageView)
        
        animaView = UIImageView()
        animaView.image = UIImage.ag_imageNamed("ic_mic_status_volume",
                                                in: "AgoraEduUI")
        animaView.isHidden  = true
        addSubview(animaView)
    }
    
    func createConstrains() {
        imageView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
        animaView.mas_makeConstraints { make in
            make?.left.right().top().bottom().equalTo()(0)
        }
    }
}
