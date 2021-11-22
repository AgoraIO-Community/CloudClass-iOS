Pod::Spec.new do |spec|
  spec.name         = "AgoraUIEduBaseViews"
  spec.version      = "1.1.5.1"
  spec.summary      = "Edu base views"
  spec.description  = "Edu base components"

  spec.homepage     = 'https://docs.agora.io/en/agora-class/landing-page?platform=iOS'
  spec.license      = { "type" => "Copyright", "text" => "Copyright 2020 agora.io. All rights reserved." }
  spec.author       = { "Agora Lab" => "developer@agora.io" }
  spec.source       = { :git => 'git@github.com:AgoraIO-Community/CloudClass-iOS.git', :tag => 'base_view_v' + "#{spec.version.to_s}" }
  spec.ios.deployment_target = "10.0"
  
  spec.module_name  = 'AgoraUIEduBaseViews'
  spec.module_map = 'SDKs/Modules/AgoraUIEduBaseViews/AgoraUIEduBaseViews/AgoraUIEduBaseViews.modulemap'
  spec.preserve_path = 'SDKs/Modules/AgoraUIEduBaseViews/AgoraUIEduBaseViews/AgoraUIEduBaseViews.modulemap'
  spec.xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }
  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'DEFINES_MODULE' => 'YES' }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'DEFINES_MODULE' => 'YES' }
  spec.pod_target_xcconfig = { 'VALID_ARCHS' => 'arm64 armv7 x86_64' }
  spec.user_target_xcconfig = { 'VALID_ARCHS' => 'arm64 armv7 x86_64' }
  spec.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4']
  
  spec.source_files  = "SDKs/Modules/AgoraUIEduBaseViews/AgoraUIEduBaseViews/**/*.{h,m,swift}", "AgoraUIEduBaseViews/**/*.{h,m,swift}"
  spec.public_header_files = "SDKs/Modules/AgoraUIEduBaseViews/AgoraUIEduBaseViews/**/*.h", "AgoraUIEduBaseViews/**/*.h"
  
  spec.dependency "AgoraEduContext"
  spec.dependency "AgoraUIBaseViews"
  spec.dependency "AgoraExtApp"
  spec.dependency "AgoraWidget"

  spec.dependency "Masonry"

  spec.subspec 'Resources' do |ss|
    ss.resource_bundles = {
      'AgoraUIEduBaseViews' => ['AgoraUIEduBaseViews/Assets/**/*.{xcassets,strings,gif,mp3}']
    }
  end
  
end
