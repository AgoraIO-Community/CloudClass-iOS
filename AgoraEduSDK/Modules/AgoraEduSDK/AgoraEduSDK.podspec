#
# Be sure to run `pod lib lint AgoraEduSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AgoraEduSDK'
  s.version          = '1.0.1'
  s.summary          = 'A short description of AgoraEduSDK.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/603722906@qq.com/AgoraEduSDK'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '603722906@qq.com' => 'sirusheng@agora.io' }
  s.source           = { :git => 'https://github.com/603722906@qq.com/AgoraEduSDK.git', :tag => s.version.to_s }

  s.platform     = :ios
  s.ios.deployment_target = '10.0'

  s.source_files  = "AgoraEduSDK/**/*.{swift,h,m}"
  s.public_header_files = [
    "AgoraEduSDK/Classes/Public/*.h", 
    "AgoraEduSDK/**/HTTP/*.h",
    "AgoraEduSDK/**/Manager/*.h",
    "AgoraEduSDK/**/AgoraRefresh/**/*.h",
    "AgoraEduSDK/**/AgoraAnimatedImage/**/*.h"
  ]

  s.private_header_files = [
    "AgoraEduSDK/**/ReportObjects/*.h"
  ]

  s.prefix_header_file = 'AgoraEduSDK/AgoraEduSDK.pch'
  s.preserve_path = 'AgoraEduSDK/AgoraEduSDK.modulemap'
  s.module_map = 'AgoraEduSDK/AgoraEduSDK.modulemap'
  s.static_framework = true
  s.frameworks = 'AudioToolbox', 'Foundation', 'UIKit'

  s.resource_bundles = {
    'AgoraEduSDK' => [
      'AgoraEduSDK/**/*.{png,xib,gif,wav,strings}', 
      'AgoraEduSDK/Classes/StoryBoards/Room/*.{storyboard}',
      'AgoraEduSDK/*.xcassets']
  }

  s.dependency "AgoraLog"
  s.dependency "EduSDK"
  s.dependency "AgoraWhiteBoard"
  s.dependency "AgoraActionProcess"
  s.dependency "AgoraReport"
  s.dependency "AgoraActionProcess"
  s.dependency "AgoraUIEduAppViews"
  s.dependency "AgoraUIEduBaseViews"
  s.dependency "AgoraUIBaseViews"
  s.dependency "AgoraExtApp"
  s.dependency "AgoraEduExtApp"
  s.dependency "AgoraEduContext"
  s.dependency "AgoraWidget"
  s.dependency "Protobuf"
  
  s.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4']
end
