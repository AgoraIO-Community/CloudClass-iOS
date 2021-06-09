Pod::Spec.new do |spec|
  spec.name         = "AgoraExtApp"
  spec.version      = "1.0.0"
  spec.summary      = "Agora extension app"
  spec.description  = "Agora extension app"

  spec.homepage     = "https://bitbucket.agoralab.co/projects/ADUC/repos/cloudclass-ios"
  spec.license      = "MIT"
  spec.author       = { "Cavan" => "suruoxi@agora.io" }
  spec.ios.deployment_target = "10.0"
  spec.source       = { :git => "ssh://git@git.agoralab.co/aduc/cloudclass-ios.git", :tag => "#{spec.version}" }
  
  spec.source_files  = "AgoraExtApp/**/*.{h,m,swift}"

  spec.module_name   = 'AgoraExtApp'
  spec.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4']
  spec.dependency "AgoraUIBaseViews"
end
