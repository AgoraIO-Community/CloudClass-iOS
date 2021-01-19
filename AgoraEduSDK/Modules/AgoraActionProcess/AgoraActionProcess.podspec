Pod::Spec.new do |spec|
  spec.name         = "AgoraActionProcess"
  spec.version      = "0.0.1"
  spec.summary      = "Agora Action Process Module."
  spec.description  = "Log component, support writing, compression upload"
  spec.homepage     = "https://github.com/AgoraIO-Usecase/eEducation"
  spec.license      = "MIT"
  spec.author             = { "SRS" => "sirusheng@agora.io" }
  spec.platform     = :ios
  spec.ios.deployment_target = "10.0"

  spec.source       = { :git => "https://github.com/AgoraIO-Usecase/eEducation.git", :tag => "#{spec.version}" }

  spec.preserve_path = 'AgoraActionProcess/AgoraActionProcess.modulemap'
  spec.module_map = 'AgoraActionProcess/AgoraActionProcess.modulemap'

  spec.subspec 'OC' do |oc_spec|
    oc_spec.source_files  = "AgoraActionProcess/**/*.{swift,h,m}"
    oc_spec.public_header_files = "AgoraActionProcess/**/*.h"
    end

  spec.subspec 'Swift' do |swift_spec|
    swift_spec.source_files  = "AgoraActionProcess/**/*.{swift,h,m}"
    swift_spec.public_header_files = "AgoraActionProcess/**/*.h"
    swift_spec.exclude_files = "AgoraActionProcess/**/AgoraActionProcessManagerOC.swift", "AgoraActionProcess/**/AgoraActionObjectOC.swift"
    end
  
  spec.swift_versions = ['5.0', '5.1', '5.2', '5.3']

  spec.dependency "AFNetworking", "4.0.1"
end
