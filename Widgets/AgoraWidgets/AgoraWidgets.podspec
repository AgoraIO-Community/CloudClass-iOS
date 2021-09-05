Pod::Spec.new do |spec|
  spec.name         = "AgoraWidgets"
  spec.version      = "1.0.0"
  spec.summary      = "Agora widgets"
  spec.description  = "Agora widgets"

  spec.homepage     = "https://bitbucket.agoralab.co/projects/ADUC/repos/cloudclass-ios"
  spec.license      = "MIT"
  spec.author       = { "Cavan" => "suruoxi@agora.io" }
  spec.source       = { :git => "ssh://git@git.agoralab.co/aduc/cloudclass-ios.git", :tag => "#{spec.version}" }
  spec.ios.deployment_target = "10.0"
  
  spec.source_files  = "**/*.{h,m,swift}"

  spec.module_name   = 'AgoraWidgets'
  spec.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4']

  spec.resource_bundles = {
    'AgoraWidgets' => [
      'AgoraResources']
  }
  
  spec.dependency "AgoraWidget"
  spec.dependency "AgoraUIBaseViews"
  spec.dependency "AgoraUIEduBaseViews"
  spec.dependency "AgoraEduContext"
end
