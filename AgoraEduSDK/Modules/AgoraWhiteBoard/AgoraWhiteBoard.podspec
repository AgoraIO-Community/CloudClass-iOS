Pod::Spec.new do |spec|
  spec.name         = "AgoraWhiteBoard"
  spec.version      = "1.0.0"
  spec.summary      = "A short description of AgoraWhiteBoard."
  spec.description  = "description of AgoraWhiteBoard"
  spec.homepage     = "https://github.com/AgoraIO-Usecase/eEducation"
  spec.license      = "MIT"
  spec.author       = { "SRS" => "sirusheng@agora.io" }
  spec.platform     = :ios
  spec.ios.deployment_target = "10.0"
  spec.source       = { :git => "https://github.com/AgoraIO-Usecase/eEducation.git", :tag => "#{spec.version}" }
  
  spec.source_files  = "AgoraWhiteBoard/*.{h,m}"
  spec.public_header_files = "AgoraWhiteBoard/*.h"
  
  spec.dependency "Whiteboard", "2.13.19-beta9"
end
