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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        createConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setVolume(_ value: Int) {
        
    }
    
    public func setState(_ state: AgoraRenderMicViewState) {
        switch state {
        case .on:
            imageView.image = UIImage.ag_imageNamed("ic_mic_status_on",
                                                    in: "AgoraEduUI")
        case .off:
            imageView.image = UIImage.ag_imageNamed("ic_mic_status_off",
                                                    in: "AgoraEduUI")
        case .forbidden:
            imageView.image = UIImage.ag_imageNamed("ic_mic_status_forbidden",
                                                    in: "AgoraEduUI")
        }
    }
}

private extension AgoraRenderMicView {
    func createViews() {
        imageView = UIImageView()
        addSubview(imageView)
        
        animaView = UIImageView()
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
