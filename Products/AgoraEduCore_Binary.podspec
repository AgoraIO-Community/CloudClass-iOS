Pod::Spec.new do |spec|
  spec.name             = 'AgoraEduCore'
  spec.version          = '5.0.0'
  spec.summary          = 'Agora Edu Core'
  spec.description      = 'Agora Edu Core SDK'

  spec.homepage     = 'https://docs.agora.io/en/agora-class/landing-page?platform=iOS'
  spec.license      = { "type" => "Copyright", "text" => "Copyright 2020 agora.io. All rights reserved." }
  spec.author       = { "Agora Lab" => "developer@agora.io" }
  spec.source       = { :git => 'ssh://git@git.agoralab.co/aduc/cloudclass-ios.git', :tag => spec.version.to_s }

  spec.ios.deployment_target = '10.0'
  spec.frameworks = 'AudioToolbox', 'Foundation', 'UIKit'

  spec.dependency "Protobuf"

  spec.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4']
  
  spec.vendored_frameworks = [
    "Libs/AgoraEduCore.framework",
    "Libs/AgoraReport.framework",
    "Libs/AgoraRte.framework",
    "Libs/AgoraRx.framework",
  ]
end
