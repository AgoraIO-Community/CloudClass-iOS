Pod::Spec.new do |s|
  s.name         = "AgoraEduUI"
  s.version      = '2.0.0'
  s.summary      = "Agora Edu UI"
  s.description  = "Agora Edu UI SDK"

  s.homepage     = 'https://docs.agora.io/en/agora-class/landing-page?platform=iOS'
  s.license      = { "type" => "Copyright", "text" => "Copyright 2020 agora.io. All rights reserved." }
  s.author       = { "Agora Lab" => "developer@agora.io" }
  s.source       = { :git => 'git@github.com:AgoraIO-Community/CloudClass-iOS.git', :tag => 'AgoraEduUI_v' + "#{s.version.to_s}" }
  s.ios.deployment_target = "10.0"
  s.module_name  = 'AgoraEduUI'

  s.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4']
  s.xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'DEFINES_MODULE' => 'YES' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'DEFINES_MODULE' => 'YES' }
  s.pod_target_xcconfig = { 'VALID_ARCHS' => 'arm64 armv7 x86_64' }
  s.user_target_xcconfig = { 'VALID_ARCHS' => 'arm64 armv7 x86_64' }
  
  s.public_header_files = "AgoraEduUI/**/*.h"
  
  s.source_files = 'AgoraEduUI/Classes/**/*.{h,m,swift}'

  s.dependency "AgoraEduContext"
  s.dependency "AgoraUIEduBaseViews"
  s.dependency "AgoraUIBaseViews"
  s.dependency "AgoraExtApp"
  s.dependency "AgoraWidget"
  s.dependency "Masonry"
  s.dependency "SwifterSwift"
  
  s.subspec 'Resources' do |ss|
    ss.resource_bundles = {
      'AgoraEduUI' => ['AgoraEduUI/Assets/**/*.{xcassets,strings,gif,mp3}']
    }
  end
  
end
