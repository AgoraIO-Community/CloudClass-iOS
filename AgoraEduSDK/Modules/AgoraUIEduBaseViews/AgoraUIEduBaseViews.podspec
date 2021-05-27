Pod::Spec.new do |spec|
  spec.name         = "AgoraUIEduBaseViews"
  spec.version      = "1.0.0"
  spec.summary      = "Edu base views"
  spec.description  = "Edu base components"

  spec.homepage     = "https://bitbucket.agoralab.co/projects/ADUC/repos/cloudclass-ios"
  spec.license      = "MIT"
  spec.author       = { "Cavan" => "suruoxi@agora.io" }
  spec.ios.deployment_target = "10.0"
  spec.source       = { :git => "ssh://git@git.agoralab.co/aduc/cloudclass-ios.git", :tag => "#{spec.version}" }
  
  spec.module_name   = 'AgoraUIEduBaseViews'
  spec.module_map = 'AgoraUIEduBaseViews/AgoraUIEduBaseViews.modulemap'
  spec.preserve_path = 'AgoraUIEduBaseViews/AgoraUIEduBaseViews.modulemap'

  spec.dependency "AgoraUIBaseViews"

  spec.subspec 'SOURCE' do |source|
    source.source_files  = "AgoraUIEduBaseViews/**/*.{h,m,swift}"
    source.public_header_files = "AgoraUIEduBaseViews/**/*.h"
    source.resource_bundles = {
      'AgoraUIEduBaseViews' => [
        'AgoraUIEduBaseViews/**/*.{png,xib,gif,wav,strings}', 
        'AgoraUIEduBaseViews/*.xcassets']
    }

    source.dependency "AgoraExtApp"
    source.dependency "AgoraEduContext"
    source.dependency "AgoraWidget"
  end

  spec.subspec 'BINARY' do |binary|
    binary.source_files  = "AgoraUIEduBaseViews/**/*.{h,m,swift}"
    binary.public_header_files = "AgoraUIEduBaseViews/**/*.h"
    binary.resource_bundles = {
      'AgoraUIEduBaseViews' => [
        'AgoraUIEduBaseViews/**/*.{png,xib,gif,wav,strings}', 
        'AgoraUIEduBaseViews/*.xcassets']
    }
    binary.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => ['$(SRCROOT)/AgoraClassroomSDK/Frameworks/', '$(SRCROOT)/../AgoraEduSDK/Frameworks/'] }
  end

  spec.subspec 'SUMBINARY' do |sub_binary|
    sub_binary.source_files  = "AgoraUIEduBaseViews/**/*.{h,m,swift}"
    sub_binary.public_header_files = "AgoraUIEduBaseViews/**/*.h"
    sub_binary.resource_bundles = {
      'AgoraUIEduBaseViews' => [
        'AgoraUIEduBaseViews/**/*.{png,xib,gif,wav,strings}', 
        'AgoraUIEduBaseViews/*.xcassets']
    }

    sub_binary.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '$(SRCROOT)/../../../Frameworks/' }
  end

  spec.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4']
  spec.default_subspec = 'BINARY'
end
