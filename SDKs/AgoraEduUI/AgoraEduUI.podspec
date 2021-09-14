Pod::Spec.new do |spec|
  spec.name         = "AgoraEduUI"
  spec.version      = "1.1.5"
  spec.summary      = "Agora Edu UI"
  spec.description  = "Agora Edu UI SDK"

  spec.homepage     = 'https://docs.agora.io/en/agora-class/landing-page?platform=iOS'
  spec.license      = { "type" => "Copyright", "text" => "Copyright 2020 agora.io. All rights reserved." }
  spec.author       = { "Agora Lab" => "developer@agora.io" }
  spec.source       = { :git => 'git@github.com:AgoraIO-Community/CloudClass-iOS.git', :tag => "#{spec.version.to_s}" }
  spec.ios.deployment_target = "10.0"
  spec.module_name   = 'AgoraEduUI'

  spec.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4']
  spec.xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }
  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'DEFINES_MODULE' => 'YES' }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'DEFINES_MODULE' => 'YES' }
  spec.pod_target_xcconfig = { 'VALID_ARCHS' => 'arm64 armv7 x86_64' }
  spec.user_target_xcconfig = { 'VALID_ARCHS' => 'arm64 armv7 x86_64' }
  
  spec.source_files = "AgoraEduUI/**/*.{h,m,swift}"
  spec.public_header_files = "AgoraEduUI/**/*.h"
  spec.resource_bundles = {
    'AgoraEduUI' => [
      'AgoraEduUI/**/*.{png,xib,gif,wav,mp3,strings}',
      'AgoraEduUI/*.xcassets']
  }

  spec.dependency "AgoraEduContext"
  spec.dependency "AgoraUIEduBaseViews"
  spec.dependency "AgoraUIBaseViews"
  spec.dependency "AgoraExtApp"
  spec.dependency "AgoraWidget"
end
