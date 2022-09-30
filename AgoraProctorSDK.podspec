Pod::Spec.new do |spec|
    spec.name         = "AgoraProctorSDK"
    spec.version      = "1.0.0"
    spec.summary      = "Invigilator scene SDK"
    spec.description  = "Agora Invigilator SDK"
    spec.homepage     = "https://docs.agora.io/en/agora-class/landing-page?platform=iOS"
    spec.license      = { "type" => "Copyright", "text" => "Copyright 2020 agora.io. All rights reserved." }
    spec.author       = { "Agora Lab" => "developer@agora.io" }
    spec.source       = { :git => "git@github.com:AgoraIO-Community/CloudClass-iOS.git", :tag => "AgoraProctorSDK_v" + "#{spec.version.to_s}" }
  
    spec.platform              = :ios
    spec.ios.deployment_target = "10.0"
    
    # open source libs
    spec.dependency "AgoraProctorUI", "1.0.0"
    
    # close source libs
    spec.dependency "AgoraWidget", ">=2.8.0"
    spec.dependency "AgoraEduCore", ">=2.8.0"
  
    spec.frameworks = "AudioToolbox", "Foundation", "UIKit"
  
    spec.pod_target_xcconfig  = { "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "arm64", "DEFINES_MODULE" => "YES" }
    spec.user_target_xcconfig = { "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "arm64", "DEFINES_MODULE" => "YES" }
    spec.pod_target_xcconfig  = { "VALID_ARCHS" => "arm64 armv7 x86_64" }
    spec.user_target_xcconfig = { "VALID_ARCHS" => "arm64 armv7 x86_64" }
    spec.xcconfig             = { "BUILD_LIBRARY_FOR_DISTRIBUTION" => "YES" }
  
    spec.source_files  = "SDKs/AgoraProctorSDK/**/*.{swift,h,m}"
    spec.public_header_files = [
        "SDKs/AgoraProctorSDK/Public/*.h"
    ]
  end
  
