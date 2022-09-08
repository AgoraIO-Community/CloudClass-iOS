//
//  FcrPlayer.swift
//  AgoraEduUI
//
//  Created by Cavan on 2022/9/6.
//

import AVFoundation

class FcrPlayer: AVPlayer {
    enum PlayerState {
        case playing, paused, stopped
    }
    
    private(set) lazy var layer = AVPlayerLayer(player: self)
    
    private var item: AVPlayerItem?
    
    private let statusKey = "status"
    
    private(set) var playState: PlayerState = .stopped
    
    static func setPlayAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback,
                                                            options: [.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("FcrPlayer setPlayAudioSession: audio session set \(error)")
        }
    }
    
    @discardableResult
    func open(url: String) -> Bool {
        guard let `url` = URL(string: url) else {
            return false
        }
        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        replaceCurrentItem(with: item)
        
        item.addObserver(self,
                         forKeyPath: statusKey,
                         options: .new,
                         context: nil)
        
        self.item = item
        
        return true
    }
    
    override func play() {
        super.play()
        playState = .playing
    }
    
    override func pause() {
        super.pause()
        playState = .paused
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        super.observeValue(forKeyPath: keyPath,
                           of: object,
                           change: change,
                           context: context)
        
        guard let `keyPath` = keyPath,
                keyPath == statusKey else {
            return
        }
        
        guard let `item` = item else {
            return
        }
        
        switch item.status {
        case .readyToPlay:
            guard playState == .playing else {
                return
            }
            
            play()
        case .failed, .unknown:
            playState = .stopped
        }
    }
}
