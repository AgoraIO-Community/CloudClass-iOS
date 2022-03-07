Pod::Spec.new do |spec|
  spec.name         = "AgoraClassroomSDK_iOS"
  spec.version      = "2.1.0"
  spec.summary      = "Education scene SDK"
  spec.description  = "Agora Classroom SDK"
  spec.homepage     = "https://docs.agora.io/en/agora-class/landing-page?platform=iOS"
  spec.license      = { "type" => "Copyright", "text" => "Copyright 2020 agora.io. All rights reserved." }
  spec.author       = { "Agora Lab" => "developer@agora.io" }
  spec.source       = { :git => "ssh://git@git.agoralab.co/aduc/open-cloudclass-ios.git", :tag => "AgoraClassroomSDK_iOS_v" + "#{spec.version.to_s}" }

  spec.platform              = :ios
  spec.ios.deployment_target = "10.0"
  
  # open source libs
  spec.dependency "AgoraEduUI"
  spec.dependency "AgoraEduContext"

  # open sources widgets and extApps
  spec.dependency "AgoraWidgets"
  
  spec.dependency "AgoraWidget"

  spec.frameworks = "AudioToolbox", "Foundation", "UIKit"

  spec.pod_target_xcconfig  = { "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "arm64", "DEFINES_MODULE" => "YES" }
  spec.user_target_xcconfig = { "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "arm64", "DEFINES_MODULE" => "YES" }
  spec.pod_target_xcconfig  = { "VALID_ARCHS" => "arm64 armv7 x86_64" }
  spec.user_target_xcconfig = { "VALID_ARCHS" => "arm64 armv7 x86_64" }
  spec.xcconfig             = { "BUILD_LIBRARY_FOR_DISTRIBUTION" => "YES" }

  spec.subspec "PreRtc" do |pre_rtc|
    pre_rtc.source_files  = "AgoraClassroomSDK/**/*.{swift,h,m}"
    pre_rtc.public_header_files = [
      "AgoraClassroomSDK/Public/*.h"
    ]
    
    # close source libs
    pre_rtc.dependency "AgoraEduCore/PreRtc"
  end
  
  spec.subspec "ReRtc" do |re_rtc|
    re_rtc.source_files  = "AgoraClassroomSDK/**/*.{swift,h,m}"
    re_rtc.public_header_files = [
      "AgoraClassroomSDK/Public/*.h"
    ]
    
    # close source libs
    re_rtc.dependency "AgoraEduCore/ReRtc"
  end

  spec.subspec "Customer" do |customer|
    customer.source_files  = "AgoraClassroomSDK/**/*.{swift,h,m}"
    customer.public_header_files = [
      "AgoraClassroomSDK/Public/*.h"
    ]
    
    # close source libs
    customer.dependency "AgoraEduCore"
  end

  spec.default_subspecs = "Customer"
end
