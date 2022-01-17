Pod::Spec.new do |spec|
  spec.name         = "AgoraClassroomSDK_iOS"
  spec.version      = "2.0.0"
  spec.summary      = "Education scene SDK"
  spec.description  = "Agora Classroom SDK"
  spec.homepage     = "https://docs.agora.io/en/agora-class/landing-page?platform=iOS"
  spec.license      = { "type" => "Copyright", "text" => "Copyright 2020 agora.io. All rights reserved." }
  spec.author       = { "Agora Lab" => "developer@agora.io" }
  spec.source       = { :git => "git@github.com:AgoraIO-Community/CloudClass-iOS.git", :tag => "AgoraClassroomSDK_iOS_v" + "#{spec.version.to_s}" }

  spec.platform              = :ios
  spec.ios.deployment_target = "10.0"
  
  spec.source_files  = "SDKs/AgoraClassroomSDK/AgoraClassroomSDK/**/*.{swift,h,m}"
  spec.public_header_files = [
      "SDKs/AgoraClassroomSDK/AgoraClassroomSDK/Public/*.h"
  ]

  # open source libs
  spec.dependency "AgoraEduUI", '2.0.0'
  spec.dependency "AgoraEduContext", '2.0.0'

  # open sources widgets and extApps
  spec.dependency "AgoraWidgets", '>= 2.0.0'
  spec.dependency "AgoraExtApps", '>= 2.0.0'

   # close source libs
  spec.dependency "AgoraEduCore", '2.0.1'

  spec.frameworks = "AudioToolbox", "Foundation", "UIKit"

  spec.pod_target_xcconfig  = { "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "arm64", "DEFINES_MODULE" => "YES" }
  spec.user_target_xcconfig = { "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "arm64", "DEFINES_MODULE" => "YES" }
  spec.pod_target_xcconfig  = { "VALID_ARCHS" => "arm64 armv7 x86_64" }
  spec.user_target_xcconfig = { "VALID_ARCHS" => "arm64 armv7 x86_64" }
  spec.xcconfig             = { "BUILD_LIBRARY_FOR_DISTRIBUTION" => "YES" }
end
