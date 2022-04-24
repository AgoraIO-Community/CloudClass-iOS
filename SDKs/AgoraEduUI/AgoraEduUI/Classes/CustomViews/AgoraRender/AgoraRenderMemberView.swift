//
//  AgoraRenderMemberView.swift
//  AgoraEduUI
//
//  Created by DoubleCircle on 2022/4/24.
//

import AgoraUIBaseViews
import FLAnimatedImage

class AgoraRenderMemberView: UIView {
    /** 画布*/
    let videoView = UIView()
    /** 状态遮罩*/
    let videoMaskView = UIImageView()
    /** 名字*/
    let nameLabel = UILabel()
    /** 麦克风视图*/
    let micView = AgoraRenderMemberMicView()
    /** 举手动画视图*/
    lazy var waveView: FLAnimatedImageView =  {
        guard let bundle = Bundle.agora_bundle(object: self,
                                               resource: "AgoraEduUI"),
              let url = bundle.url(forResource: "img_hands_wave",
                                   withExtension: "gif"),
              let data = try? Data(contentsOf: url) else {
            fatalError()
        }
        
        let animatedImage = FLAnimatedImage(animatedGIFData: data)
        let v = FLAnimatedImageView()
        v.animatedImage = animatedImage
        v.isHidden = true
        self.addSubview(v)
        v.mas_makeConstraints { make in
            make?.width.height().equalTo()(self.mas_height)
            make?.centerX.bottom().equalTo()(0)
        }
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
    }
}
