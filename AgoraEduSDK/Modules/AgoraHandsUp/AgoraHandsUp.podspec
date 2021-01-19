Pod::Spec.new do |spec|
  spec.name         = "AgoraHandsUp"
  spec.version      = "0.0.1"
  spec.summary      = "Agora HandsUp Module."
  spec.description  = "Log component, support writing, compression upload"
  spec.homepage     = "https://github.com/AgoraIO-Usecase/eEducation"
  spec.license      = "MIT"
  spec.author             = { "SRS" => "sirusheng@agora.io" }
  spec.platform     = :ios
  spec.ios.deployment_target = "10.0"

  spec.source       = { :git => "https://github.com/AgoraIO-Usecase/eEducation.git", :tag => "#{spec.version}" }

  spec.subspec 'OC' do |oc_spec|
    oc_spec.resources = "AgoraHandsUp/**/*.{png,xcassets,xib,bundle}"
    
    oc_spec.source_files  = "AgoraHandsUp/**/*.{swift}"
    end

  spec.subspec 'Swift' do |swift_spec|
    swift_spec.resources = "AgoraHandsUp/**/*.{png,xcassets,xib,bundle}"
    
    swift_spec.source_files  = "AgoraHandsUp/**/*.{swift}"
    swift_spec.exclude_files = "AgoraHandsUp/**/AgoraHandsUpManagerOC.swift"
    end
  
  spec.swift_versions = ['5.0', '5.1', '5.2', '5.3']
end
