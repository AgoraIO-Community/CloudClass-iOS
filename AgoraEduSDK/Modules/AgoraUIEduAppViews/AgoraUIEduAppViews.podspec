Pod::Spec.new do |spec|
  spec.name         = "AgoraUIEduAppViews"
  spec.version      = "1.0.0"
  spec.summary      = "Agora Edu App Views"
  spec.description  = "Agora Edu App Views"

  spec.homepage     = "https://bitbucket.agoralab.co/projects/ADUC/repos/cloudclass-ios"
  spec.license      = "MIT"
  spec.author       = { "Cavan" => "suruoxi@agora.io" }
  spec.ios.deployment_target = "10.0"
  spec.source       = { :git => "ssh://git@git.agoralab.co/aduc/cloudclass-ios.git", :tag => "#{spec.version}" }
  
  spec.module_name   = 'AgoraUIEduAppViews'


  spec.dependency "AgoraUIBaseViews"

  spec.subspec 'SOURCE' do |source|
    source.source_files = "AgoraUIEduAppViews/**/*.{h,m,swift}"
    source.public_header_files = "AgoraUIEduAppViews/**/*.h"
    source.resource_bundles = {
      'AgoraUIEduAppViews' => [
        'AgoraUIEduAppViews/**/*.{png,xib,gif,wav,mp3,strings}',
        'AgoraUIEduAppViews/*.xcassets']
    }

    source.dependency "AgoraUIEduBaseViews/SOURCE"
    source.dependency "AgoraExtApp"
    source.dependency "AgoraEduContext"
  end

  spec.subspec 'BINARY' do |binary|
    binary.source_files = "AgoraUIEduAppViews/**/*.{h,m,swift}"
    binary.public_header_files = "AgoraUIEduAppViews/**/*.h"
    binary.dependency "AgoraUIEduBaseViews/BINARY" 
    binary.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => ['$(SRCROOT)/AgoraClassroomSDK/Frameworks/', '$(SRCROOT)/../AgoraEduSDK/Frameworks/'] }
    
    binary.resource_bundles = {
      'AgoraUIEduAppViews' => [
        'AgoraUIEduAppViews/**/*.{png,xib,gif,wav,mp3,strings}',
        'AgoraUIEduAppViews/*.xcassets']
    }
  end

  spec.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4']
  spec.default_subspec = 'BINARY'
end
