Pod::Spec.new do |spec|
  spec.name         = 'AgoraClassroomSDK'
  spec.version      = '2.6.1'
  spec.summary      = 'Education scene SDK'

  spec.description  = "Education scene binary SDK "

  spec.homepage     = 'https://docs.agora.io/en/agora-class/landing-page?platform=iOS'
  spec.license      = { "type" => "Copyright", "text" => "Copyright 2020 agora.io. All rights reserved." }
  spec.author       = { "Agora Lab" => "developer@agora.io" }
  spec.source       = { :git => 'hgit@github.com:AgoraIO-Community/CloudClass-iOS.git', :tag => spec.version.to_s }

  spec.ios.deployment_target = '10.0'
  spec.frameworks = 'AudioToolbox', 'Foundation', 'UIKit'
  spec.xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' } 
  
  spec.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => ['$(SRCROOT)/../Products/Libs/'] }

  spec.vendored_frameworks = [
    "Libs/*.framework"
  ]
end
