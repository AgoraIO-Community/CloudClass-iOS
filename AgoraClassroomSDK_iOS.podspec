Pod::Spec.new do |spec|
  spec.name         = "AgoraClassroomSDK_iOS"
  spec.version      = "2.7.1"
  spec.summary      = "Education scene SDK"
  spec.description  = "Agora Classroom SDK"
  spec.homepage     = "https://docs.agora.io/en/agora-class/landing-page?platform=iOS"
  spec.license      = { "type" => "Copyright", "text" => "Copyright 2020 agora.io. All rights reserved." }
  spec.author       = { "Agora Lab" => "developer@agora.io" }
  spec.source       = { :git => "git@github.com:AgoraIO-Community/CloudClass-iOS.git", :tag => "AgoraClassroomSDK_iOS_v" + "#{spec.version.to_s}" }

  spec.platform              = :ios
  spec.ios.deployment_target = "10.0"
  
  # open source libs
  spec.dependency "AgoraEduUI", ">=2.7.1"
  spec.dependency "AgoraEduContext", "2.7.0"

  # open sources widgets
  spec.dependency "AgoraWidgets", ">=2.7.1"
  
  # close source libs
  spec.dependency "AgoraEduCore", ">=2.7.1"
  spec.dependency "AgoraWidget", ">=2.6.0"

  spec.frameworks = "AudioToolbox", "Foundation", "UIKit"

  spec.pod_target_xcconfig  = { "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "arm64", "DEFINES_MODULE" => "YES" }
  spec.user_target_xcconfig = { "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "arm64", "DEFINES_MODULE" => "YES" }
  spec.pod_target_xcconfig  = { "VALID_ARCHS" => "arm64 armv7 x86_64" }
  spec.user_target_xcconfig = { "VALID_ARCHS" => "arm64 armv7 x86_64" }
  spec.xcconfig             = { "BUILD_LIBRARY_FOR_DISTRIBUTION" => "YES" }

  spec.source_files  = "SDKs/AgoraClassroomSDK/**/*.{swift,h,m}"
  spec.public_header_files = [
      "SDKs/AgoraClassroomSDK/Public/*.h"
  ]
end
