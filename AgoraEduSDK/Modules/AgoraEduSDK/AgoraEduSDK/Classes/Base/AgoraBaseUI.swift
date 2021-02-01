//
//  AgoraBaseUI.swift
//  ApaasTest
//
//  Created by Cavan on 2021/1/31.
//

import UIKit

class AgoraBaseUIView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        agora_init_base_view()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        agora_init_base_view()
    }
}

class AgoraBaseUILabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        agora_init_base_view()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        agora_init_base_view()
    }
}

class AgoraBaseUIButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        agora_init_base_view()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        agora_init_base_view()
    }
}

class AgoraBaseUICollectionView: UICollectionView {
    override init(frame: CGRect,
                  collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame,
                   collectionViewLayout: layout)
        agora_init_base_view()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        agora_init_base_view()
    }
}

class AgoraBaseUICollectionCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        agora_init_base_view()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        agora_init_base_view()
    }
}
