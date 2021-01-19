#
# Be sure to run `pod lib lint AgoraEduSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AgoraEduSDK'
  s.version          = '0.1.0'
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
  s.public_header_files = "AgoraEduSDK/Classes/Public/*.h"
  s.prefix_header_file = 'AgoraEduSDK/Classes/AgoraEduSDK.pch'
  s.static_framework = true

  s.resource_bundles = {
    'AgoraEduSDK' => [
      'AgoraEduSDK/**/*.{png,xib,bundle,gif,strings}', 
      'AgoraEduSDK/Classes/StoryBoards/Room/*.{storyboard}',
      'AgoraEduSDK/*.xcassets']
  }

  s.dependency "AgoraLog"
  s.dependency "EduSDK"
  s.dependency "AgoraWhiteBoard"
  s.dependency "AgoraHandsUp"
  s.dependency "AgoraActionProcess"
  s.dependency "AgoraReplay"
  s.dependency "AgoraReplayUI"

end
