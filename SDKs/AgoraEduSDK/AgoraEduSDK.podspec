Pod::Spec.new do |spec|
  spec.name             = 'AgoraEduSDK'
  spec.version          = '1.1.5'
  spec.summary          = 'Education scene SDK'
  spec.description      = 'Agora Edu Scene SDK'

  spec.homepage     = 'https://docs.agora.io/en/agora-class/landing-page?platform=iOS'
  spec.license      = { "type" => "Copyright", "text" => "Copyright 2020 agora.io. All rights reserved." }
  spec.author       = { "Agora Lab" => "developer@agora.io" }
  spec.source       = { :git => 'git@github.com:AgoraIO-Community/CloudClass-iOS.git', :tag => spec.version.to_s }

  spec.platform     = :ios
  spec.ios.deployment_target = '10.0'
  spec.frameworks = 'AudioToolbox', 'Foundation', 'UIKit'

  spec.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4']

  spec.source_files  = "AgoraEduSDK/**/*.{swift,h,m}"
  spec.public_header_files = [
    "AgoraEduSDK/Public/*.h", 
  ]
    
  # close source libs
  spec.dependency "AgoraEduCore"

  # common libs
  spec.dependency "AgoraExtApp"
  spec.dependency "AgoraWidget"

  # open source libs
  spec.dependency "AgoraEduUI"
  spec.dependency "AgoraEduContext"
  spec.dependency "AgoraWidgets"

  # third part libs
  spec.dependency "Whiteboard"
end
