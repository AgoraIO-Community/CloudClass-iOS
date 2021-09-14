Pod::Spec.new do |spec|
  spec.name         = "AgoraWidgets"
  spec.version      = "1.0.0"
  spec.summary      = "Agora widgets"
  spec.description  = "Agora native widgets"

  spec.homepage     = 'https://docs.agora.io/en/agora-class/landing-page?platform=iOS'
  spec.license      = { "type" => "Copyright", "text" => "Copyright 2020 agora.io. All rights reserved." }
  spec.author       = { "Agora Lab" => "developer@agora.io" }
  spec.source       = { :git => "git@github.com:AgoraIO-Community/CloudClass-iOS.git", :tag => 'agora_widgets_v' + "#{spec.version.to_s}" }
  spec.ios.deployment_target = "10.0"
  
  spec.module_name   = 'AgoraWidgets'
  spec.xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }
  spec.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4']
  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'DEFINES_MODULE' => 'YES' }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'DEFINES_MODULE' => 'YES' }
  spec.pod_target_xcconfig = { 'VALID_ARCHS' => 'arm64 armv7 x86_64' }
  spec.user_target_xcconfig = { 'VALID_ARCHS' => 'arm64 armv7 x86_64' }

  spec.source_files  = "Widgets/AgoraWidgets/**/*.{h,m,swift}", "Chat/*.{h,m,swift}", "Common/*.{h,m,swift}"
  spec.resource_bundles = {
    'AgoraWidgets' => [
      "AgoraResources", 
      "Widgets/AgoraWidgets/AgoraResources"]
  }
  
  spec.dependency "AgoraWidget"
  spec.dependency "AgoraUIBaseViews"
  spec.dependency "AgoraUIEduBaseViews"
  spec.dependency "AgoraEduContext"
end
