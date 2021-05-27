Pod::Spec.new do |spec|
  spec.name         = "AgoraReport"
  spec.version      = "1.0.0"
  spec.summary      = "Report event"
  spec.homepage     = "https://bitbucket.agoralab.co/projects/ADUC/repos/cloudclass-ios"
  spec.license      = "MIT"
  spec.author       = { "CavanSu" => "403029552@qq.com" }
  spec.platform     = :ios
  spec.ios.deployment_target = "10.0"
  spec.source       = { :git => "ssh://git@git.agoralab.co/aduc/cloudclass-ios.git", :tag => "#{spec.version}" }

  spec.source_files  = "AgoraReport/**/*.{swift,h,m}"
  spec.dependency "AFNetworking", "4.0.1"
  spec.module_name   = 'AgoraReport'
  spec.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4']

  # spec.pod_target_xcconfig = {"OTHER_SWIFT_FLAGS[config=Debug]" => "-D AGORADEBUG" }
end
