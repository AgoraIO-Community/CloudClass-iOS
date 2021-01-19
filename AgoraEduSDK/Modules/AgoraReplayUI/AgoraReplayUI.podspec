Pod::Spec.new do |spec|
  spec.name         = "AgoraReplayUI"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of AgoraReplayUI."
  spec.description  = "description of AgoraReplayUI"
  spec.homepage     = "https://github.com/AgoraIO-Usecase/eEducation"
  spec.license      = "MIT"
  spec.author             = { "SRS" => "sirusheng@agora.io" }
  spec.platform     = :ios
  spec.ios.deployment_target = "10.0"
  spec.source       = { :git => "https://github.com/AgoraIO-Usecase/eEducation.git", :tag => "#{spec.version}" }
  spec.source_files  = "AgoraReplayUI/**/*.{h,m}"
  spec.public_header_files = "AgoraReplayUI/**/*.h"
  spec.resources = "AgoraReplayUI/**/*.{png,xcassets,xib,bundle}"
 
  spec.dependency "AgoraReplay"
  spec.dependency "Whiteboard", "2.9.14"

end
