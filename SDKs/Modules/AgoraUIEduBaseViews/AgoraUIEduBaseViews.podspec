Pod::Spec.new do |spec|
  spec.name         = "AgoraUIEduBaseViews"
  spec.version      = "1.1.5"
  spec.summary      = "Edu base views"
  spec.description  = "Edu base components"

  spec.homepage     = 'https://docs.agora.io/en/agora-class/landing-page?platform=iOS'
  spec.license      = { "type" => "Copyright", "text" => "Copyright 2020 agora.io. All rights reserved." }
  spec.author       = { "Agora Lab" => "developer@agora.io" }
  spec.source       = { :git => 'git@github.com:AgoraIO-Community/CloudClass-iOS.git', :tag => "#{spec.version.to_s}" }
  spec.ios.deployment_target = "10.0"
  
  spec.module_name   = 'AgoraUIEduBaseViews'
  spec.module_map = 'AgoraUIEduBaseViews/AgoraUIEduBaseViews.modulemap'
  spec.preserve_path = 'AgoraUIEduBaseViews/AgoraUIEduBaseViews.modulemap'
  spec.xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }
  spec.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4']
  spec.source_files  = "AgoraUIEduBaseViews/**/*.{h,m,swift}"
  spec.public_header_files = "AgoraUIEduBaseViews/**/*.h"
  spec.resource_bundles = {
    'AgoraUIEduBaseViews' => [
      'AgoraUIEduBaseViews/**/*.{png,xib,gif,wav,strings}', 
      'AgoraUIEduBaseViews/*.xcassets']
  }

  spec.dependency "AgoraEduContext"
  spec.dependency "AgoraUIBaseViews"
  spec.dependency "AgoraExtApp"
  spec.dependency "AgoraWidget"
end
