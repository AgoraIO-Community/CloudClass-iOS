Pod::Spec.new do |spec|
  spec.name             = 'AgoraExtApp'
  spec.version          = '1.0.0'
  spec.summary          = 'Agora Ext App'
  spec.description      = 'Agora Ext App SDK'

  spec.homepage     = 'https://docs.agora.io/en/agora-class/landing-page?platform=iOS'
  spec.license      = { "type" => "Copyright", "text" => "Copyright 2020 agora.io. All rights reserved." }
  spec.author       = { "Agora Lab" => "developer@agora.io" }
  spec.source       = { :git => 'ssh://git@git.agoralab.co/aduc/cloudclass-ios.git', :tag => spec.version.to_s }

  spec.ios.deployment_target = '10.0'
  spec.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4']
  
  # close source
  spec.dependency "AgoraUIBaseViews"

  spec.vendored_frameworks = [
    "AgoraExtApp.framework"
  ]
end
