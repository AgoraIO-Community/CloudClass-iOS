Pod::Spec.new do |spec|
  spec.name         = "AgoraUIBaseViews"
  spec.version      = "1.0.0"
  spec.summary      = "Agora Base Views"
  spec.description  = "Agora Base Views"

  spec.homepage     = "https://bitbucket.agoralab.co/projects/ADUC/repos/cloudclass-ios"
  spec.license      = "MIT"
  spec.author       = { "Cavan" => "suruoxi@agora.io" }
  spec.ios.deployment_target = "10.0"
  spec.source       = { :git => "ssh://git@git.agoralab.co/aduc/cloudclass-ios.git", :tag => "#{spec.version}" }
  
  spec.source_files = "AgoraUIBaseViews/*.{h,m,swift}"
  spec.public_header_files = "AgoraUIBaseViews/*.h"

  spec.source_files  = "AgoraUIBaseViews/*.{h,m,swift}"
  spec.public_header_files = "AgoraUIBaseViews/*.h"
  spec.module_name   = 'AgoraUIBaseViews'
  spec.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4']
end
