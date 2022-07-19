//
//  FcrEnvironment.swift
//  AgoraEducation
//
//  Created by Jonathan on 2022/7/7.
//  Copyright © 2022 Agora. All rights reserved.
//

import UIKit

class FcrEnvironment {
    
    private let kRegion = "com.agora.region"
    private let kEnvironment = "com.agora.environment"
    
    static let shared = FcrEnvironment()
    
    public var server = "https://api-solutions-dev.bj2.agoralab.co"
    
    enum Environment: String {
        case dev, pre, pro
    }
    
    enum Region: String {
        case CN, NA, EU, AP
    }
    // environment
    private lazy var _environment: Environment = {
        let saved = UserDefaults.standard.object(forKey: kEnvironment) as? String
        return Environment(rawValue: saved ?? "pro") ?? Environment.pro
    }()
    var environment: Environment {
        set {
            _environment = newValue
            UserDefaults.standard.set(newValue.rawValue, forKey: kEnvironment)
            updateBaseURL()
        }
        get {
            return _environment
        }
    }
    // region
    private lazy var _region: Region = {
        let saved = UserDefaults.standard.object(forKey: kRegion) as? String
        return Region(rawValue: saved ?? "CN") ?? Region.CN
    }()
    var region: Region {
        set {
            _region = newValue
            UserDefaults.standard.set(newValue.rawValue, forKey: kRegion)
            updateBaseURL()
        }
        get {
            return _region
        }
    }
    
    func updateBaseURL() {
        switch environment {
        case .dev:
            server = "https://api-solutions-dev.bj2.agoralab.co"
        case .pre:
            server = "https://api-solutions-pre.bj2.agoralab.co"
        case .pro:
            switch region {
            case .CN:
                server = "https://api-solutions.bj2.agoralab.co"
            case .NA:
                server = "https://api-solutions.sv3sbm.agoralab.co"
            case .EU:
                server = "https://api-solutions.fr3sbm.agoralab.co"
            case .AP:
                server = "https://api-solutions.sg3sbm.agoralab.co"
            }
        }
    }
    
    init() {
        updateBaseURL()
    }
}
