Pod::Spec.new do |spec|
  spec.name         = "AgoraEduUI"
  spec.version      = "2.8.0"
  spec.summary      = "Agora Edu UI"
  spec.description  = "Agora Edu UI SDK"
  spec.homepage     = "https://docs.agora.io/en/agora-class/landing-page?platform=iOS"
  spec.license      = { "type" => "Copyright", "text" => "Copyright 2020 agora.io. All rights reserved." }
  spec.author       = { "Agora Lab" => "developer@agora.io" }
  spec.module_name  = "AgoraEduUI"

  spec.ios.deployment_target = "10.0"
  spec.swift_versions        = ["5.0", "5.1", "5.2", "5.3", "5.4"]

  spec.source              = { :git => "git@github.com:AgoraIO-Community/CloudClass-iOS.git", :tag => "AgoraEduUI_v" + "#{spec.version.to_s}" }
  
  spec.dependency "AgoraUIBaseViews/Binary"
  spec.dependency "AgoraEduCore/Binary"
  spec.dependency "AgoraWidget/Binary"
  spec.dependency "SwifterSwift"
  spec.dependency "Masonry"
  
  spec.pod_target_xcconfig  = { "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "arm64", "DEFINES_MODULE" => "YES" }
  spec.user_target_xcconfig = { "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "arm64", "DEFINES_MODULE" => "YES" }
  spec.pod_target_xcconfig  = { "VALID_ARCHS" => "arm64 armv7 x86_64" } 
  spec.user_target_xcconfig = { "VALID_ARCHS" => "arm64 armv7 x86_64" }
  spec.xcconfig             = { "BUILD_LIBRARY_FOR_DISTRIBUTION" => "YES" }

  spec.subspec "Resources" do |ss|
    ss.resource_bundles = {
      "AgoraEduUI" => ["SDKs/AgoraEduUI/Assets/**/*.{xcassets,strings,gif,mp3}"]
    }
  end
  
  spec.subspec "Source" do |ss|
    ss.public_header_files = "SDKs/AgoraEduUI/Classes/**/*.h"
    ss.source_files        = "SDKs/AgoraEduUI/Classes/**/*.{h,m,swift}"
  end
  
  spec.subspec "Binary" do |ss|
    ss.vendored_frameworks = [
      "Products/Libs/AgoraEduUI/*.framework"
    ]
  end

  spec.default_subspec = "Source"
end
