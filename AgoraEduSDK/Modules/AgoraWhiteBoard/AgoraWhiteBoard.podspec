Pod::Spec.new do |spec|
  spec.name         = "AgoraWhiteBoard"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of AgoraWhiteBoard."
  spec.description  = "description of AgoraWhiteBoard"
  spec.homepage     = "https://github.com/AgoraIO-Usecase/eEducation"
  spec.license      = "MIT"
  spec.author             = { "SRS" => "sirusheng@agora.io" }
  spec.platform     = :ios
  spec.ios.deployment_target = "10.0"
  spec.source       = { :git => "https://github.com/AgoraIO-Usecase/eEducation.git", :tag => "#{spec.version}" }
  
  spec.source_files  = "AgoraWhiteBoard/**/*.{h,m}"
  spec.public_header_files = "AgoraWhiteBoard/**/*.h"
  spec.resources = "AgoraWhiteBoard/**/*.{png,xcassets,xib,bundle}"
  
  spec.dependency "Whiteboard", "2.9.14"
end
