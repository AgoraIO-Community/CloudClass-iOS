//
//  FcrUIAudioRawDataTester.swift
//  AgoraEduUI
//
//  Created by Cavan on 2023/4/23.
//

import AgoraEduCore

class FcrUIAudioRawDataTester: NSObject, FcrAudioRawDataObserver {
    weak var mediaController: AgoraEduMediaContext?
    
    let recordWriter = FcrUIFileWriter()
    
    let beforeMixedWriter = FcrUIFileWriter()
    
    let mixedWriter = FcrUIFileWriter()
    
    init(mediaController: AgoraEduMediaContext) {
        super.init()
        self.mediaController = mediaController
    }
    
    func startTest() {
        startTestAudioData(position: .record)
//        startTestAudioData(position: .beforeMixed)
//        startTestAudioData(position: .mixed)
//
//        stopTestAudioData(position: .record)
//        stopTestAudioData(position: .beforeMixed)
//        stopTestAudioData(position: .mixed)
    }
    
    private func startTestAudioData(position: FcrAudioRawDataPosition) {
        guard let media = mediaController else {
            return
        }
        
        let sampleSize: UInt8 = 2
        let duration: Int32 = 30 // second
        let sampleRate: UInt64 = 441000
        let channels: UInt8 = 1
        
        let config = FcrAudioRawDataConfig()
        
        config.sampleRate = sampleRate
        config.channels = channels
        
        let byteLimit = config.sampleRate * UInt64(config.channels) * UInt64(sampleSize) * UInt64(duration)
        
        var writer: FcrUIFileWriter
        
        switch position {
        case .record:
            writer = recordWriter
        case .beforeMixed:
            writer = beforeMixedWriter
        case .mixed:
            writer = mixedWriter
        }
        
        writer.byteLimit = byteLimit
        
        media.setAudioRawDataConfig(config: config,
                                    position: position)
        
        media.addAudioRawDataObserver(observer: self,
                                      position: position)
    }
    
    private func stopTestAudioData(position: FcrAudioRawDataPosition) {
        guard let media = mediaController else {
            return
        }
        
        media.removeAudioRawDataObserver(observer: self,
                                         position: position)
    }
    
    func onAudioRawDataRecorded(data: FcrAudioRawData) {
        print(">>>>>>>>>>>>>>> onAudioRawDataRecorded, \(data.sampleRate), \(data.channels)")
        
        recordWriter.write(data: data.buffer,
                           to: "record_audio_rawdata.pcm")
    }
    
    // sample rate: 44.1k, channels: 2
    func onAudioRawDataBeforeMixed(data: FcrAudioRawData,
                                   streamUuid: NSString,
                                   sceneId: NSString) {
//        print(">>>>>>>>>>>>>>> onAudioRawDataBeforeMixed, \(data.sampleRate), \(data.channels)")
        
        beforeMixedWriter.write(data: data.buffer,
                                to: "before_mixed_audio_rawdata_\(streamUuid)_\(sceneId).pcm")
    }
    
    func onAudioRawDataMixed(data: FcrAudioRawData) {
//        print(">>>>>>>>>>>>>>> onAudioRawDataMixed, \(data.sampleRate), \(data.channels)")
        
        mixedWriter.write(data: data.buffer,
                          to: "mixed_audio_rawdata.pcm")
    }
}
