Pod::Spec.new do |spec|
  spec.name         = "EduSDK"
  spec.version      = "1.0.0"
  spec.summary      = "A short description of EduSDK."
  spec.description  = "Manage classroom information, including students and teachers. And the corresponding events"

  spec.homepage     = "https://github.com/AgoraIO-Usecase/eEducation"
  spec.license      = "MIT"
  spec.author             = { "SRS" => "sirusheng@agora.io" }
  spec.platform     = :ios
  spec.ios.deployment_target = "10.0"
  spec.source       = { :git => "https://github.com/AgoraIO-Usecase/eEducation.git", :tag => "#{spec.version}" }

  spec.source_files = "EduSDK/**/*.{h,m,swift}"
  spec.public_header_files = "EduSDK/**/*.h"
  spec.static_framework = true

  spec.dependency "AgoraRtcEngine_Special_iOS", "2.9.107.136"
  spec.dependency "AgoraLog"
  spec.dependency "YYModel", "1.0.4"
  spec.dependency "AgoraRtm_iOS", "1.4.1"
  spec.dependency "AgoraReport"

  spec.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4']
end
