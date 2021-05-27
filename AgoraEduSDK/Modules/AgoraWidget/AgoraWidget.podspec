Pod::Spec.new do |spec|
  spec.name         = "AgoraWidget"
  spec.version      = "1.0.0"
  spec.summary      = "Agora widget"
  spec.description  = "Agora widget"

  spec.homepage     = "https://bitbucket.agoralab.co/projects/ADUC/repos/cloudclass-ios"
  spec.license      = "MIT"
  spec.author       = { "Cavan" => "suruoxi@agora.io" }
  spec.ios.deployment_target = "10.0"
  spec.source       = { :git => "ssh://git@git.agoralab.co/aduc/cloudclass-ios.git", :tag => "#{spec.version}" }
  
  spec.public_header_files = "AgoraWidget/**/*.h"
  spec.source_files  = "AgoraWidget/**/*.{h,m,swift}"

  spec.module_name   = 'AgoraWidget'
  spec.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4']
  spec.dependency "AgoraUIBaseViews"
end
