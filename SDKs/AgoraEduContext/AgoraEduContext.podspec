Pod::Spec.new do |spec|
  spec.name             = 'AgoraEduContext'
  spec.version          = '1.1.5'
  spec.summary          = 'Edu Context'
  spec.description      = 'Agora Edu Context'

  spec.homepage     = 'https://docs.agora.io/en/agora-class/landing-page?platform=iOS'
  spec.license      = { "type" => "Copyright", "text" => "Copyright 2020 agora.io. All rights reserved." }
  spec.author       = { "Agora Lab" => "developer@agora.io" }
  spec.source       = { :git => 'git@github.com:AgoraIO-Community/CloudClass-iOS.git', :tag => 'v' + "#{spec.version.to_s}" }
  
  spec.platform    = :ios
  spec.ios.deployment_target = '10.0'
  spec.source_files  = "SDKs/AgoraEduContext/AgoraEduContext/*.{swift,h,m}", "AgoraEduContext/*.{swift,h,m}"
  spec.public_header_files = [
    "AgoraEduContext/*.h", 
    "SDKs/AgoraEduContext/AgoraEduContext/*.h"
  ]

  spec.xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }
  spec.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4']
  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'DEFINES_MODULE' => 'YES' }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'DEFINES_MODULE' => 'YES' }
  spec.pod_target_xcconfig = { 'VALID_ARCHS' => 'arm64 armv7 x86_64' }
  spec.user_target_xcconfig = { 'VALID_ARCHS' => 'arm64 armv7 x86_64' }

  spec.dependency "AgoraUIBaseViews"
  spec.dependency "AgoraExtApp"
  spec.dependency "AgoraWidget"
end
