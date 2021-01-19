#
# Be sure to run `pod lib lint EduApplication.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AgoraEduSDK'
  s.version          = '1.0.0'
  s.summary          = 'Agora Education SDK'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  AgoraEduSDK includes the information management in the room, and also includes three educational scenarios: 'One to One', 'Small Classroom' and 'Lecture Hall'. You can quickly build an education app through the AgoraEduSDK.
                       DESC

  s.homepage         = 'https://docs.agora.io'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jerry' => 'sirusheng@agora.io' }
  s.source           = { :http => 'https://github.com/srs888001/EduApplication/releases/download/untagged-26ff37c5b2f392216128/Frameworks.zip' }
 
  s.platform = :ios
  s.ios.deployment_target = '10.0'
  s.resource_bundles = {
    'AgoraEduSDK' => [
      'Frameworks/AgoraEduSDK.framework/AgoraEduSDK.bundle/*'
    ],
  }

  s.dependency "AgoraRtm_iOS", "1.4.1"
  s.dependency "AgoraRtcEngine_iOS", "2.9.0.107"
  s.dependency "AFNetworking", "4.0.1"
  s.dependency "Whiteboard", "2.9.14"
  s.dependency "CocoaLumberjack", "3.6.1"
  s.dependency "AliyunOSSiOS", "2.10.8"

  s.subspec 'AgoraALL' do |spec|
    spec.vendored_frameworks = [
      "Frameworks/AgoraEduSDK.framework", 
      "Frameworks/EduSDK.framework", 
      "Frameworks/AgoraLog.framework", 
      "Frameworks/AgoraWhiteBoard.framework", 
      "Frameworks/AgoraReplay.framework", 
      "Frameworks/AgoraReplayUI.framework"
    ]
  end

  s.subspec 'AgoraEdu' do |spec|
    spec.resource_bundles = {
      'AgoraEduSDK' => [
        'Frameworks/AgoraEduSDK.framework/AgoraEduSDK.bundle/*'
      ],
    }
    spec.vendored_frameworks = [
      "Frameworks/AgoraEduSDK.framework", 
      "Frameworks/EduSDK.framework", 
      "Frameworks/AgoraLog.framework", 
      "Frameworks/AgoraWhiteBoard.framework"
    ]
  end

  s.default_subspecs = 'AgoraALL'

  s.requires_arc = true

  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

end