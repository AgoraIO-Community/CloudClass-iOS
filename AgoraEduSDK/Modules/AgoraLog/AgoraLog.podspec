Pod::Spec.new do |spec|

  spec.name         = "AgoraLog"
  spec.version      = "0.0.2"
  spec.summary      = "Agora Log Module."
  spec.description  = "Log component, support writing, compression upload"

  spec.homepage     = "https://github.com/AgoraIO-Usecase/eEducation"
  spec.license      = "MIT"
  spec.author             = { "SRS" => "sirusheng@agora.io" }
  spec.platform     = :ios
  spec.ios.deployment_target = "10.0"
  spec.source       = { :git => "https://github.com/AgoraIO-Usecase/eEducation.git", :tag => "#{spec.version}" }
  spec.source_files  = "AgoraLog/**/*.{h,m,c}"
  spec.public_header_files = "AgoraLog/**/*.h"
  
  spec.dependency "AFNetworking", "4.0.1"
  spec.dependency "CocoaLumberjack", "3.6.1"
  spec.dependency "AliyunOSSiOS", "2.10.8"

end
