//
//  AgoraSubThreadTimer.swift
//  AgoraReport
//
//  Created by SRS on 2021/2/18.
//

import Foundation

@objc public protocol AgoraSubThreadTimerDelegate: NSObjectProtocol {
    func perLoop()
}

@objcMembers open class AgoraSubThreadTimer: NSObject {
    public weak var delegate: AgoraSubThreadTimerDelegate?
    
    private var thread: Thread?
    private var subRunLoop: RunLoop?
    private var timer: Timer?
    private var threadName: String
    private var interval: TimeInterval = 0
    
    public init(threadName: String,
                timeInterval: TimeInterval) {
        self.threadName = threadName
        self.interval = timeInterval
    }
    
    public func start() {
        if self.thread != nil {
            return
        }
        
        let thread = Thread(target: self,
                             selector: #selector(run),
                             object: nil)
        thread.name = self.threadName
        thread.start()
        
        self.thread = thread
    }
    
    public func stop() {
        self.timer?.invalidate()
        self.timer = nil
        
        if let runLoop = self.subRunLoop {
            let cfRunloop = runLoop.getCFRunLoop()
            CFRunLoopStop(cfRunloop)
            self.subRunLoop = nil
        }
        
        self.thread = nil
    }

    @objc private func run() {
        let subRunLoop =  RunLoop.current
        let timer = Timer(timeInterval: self.interval,
                          target: self,
                          selector: #selector(loop),
                          userInfo: nil,
                          repeats: true)
        
        subRunLoop.add(timer,
                       forMode: .common)
        subRunLoop.run(mode: .default,
                       before: NSDate.distantFuture)
        subRunLoop.run(mode: .common,
                       before: NSDate.distantFuture)
        
        self.subRunLoop = subRunLoop
        self.timer = timer
    }
    
    @objc private func loop() {
        self.delegate?.perLoop()
    }
    
    deinit {
        self.stop()
    }
}
