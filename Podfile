# Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
inhibit_all_warnings!


def sourcePod
  pod 'AgoraEduSDK', :path => 'AgoraEduSDK/Modules/AgoraEduSDK/AgoraEduSDK.podspec'
  
  pod 'AgoraLog', :path => 'AgoraEduSDK/Modules/AgoraLog/AgoraLog.podspec'
  pod 'EduSDK', :path => 'AgoraEduSDK/Modules/EduSDK/EduSDK.podspec'
  pod 'AgoraWhiteBoard', :path => 'AgoraEduSDK/Modules/AgoraWhiteBoard/AgoraWhiteBoard.podspec'
  
  pod 'AgoraReplay', :path => 'AgoraEduSDK/Modules/AgoraReplay/AgoraReplay.podspec'
  pod 'AgoraReplayUI', :path => 'AgoraEduSDK/Modules/AgoraReplayUI/AgoraReplayUI.podspec'

  # if you use swift project, you just only change 'OC' to 'Swift'
  pod 'AgoraHandsUp', :path => 'AgoraEduSDK/Modules/AgoraHandsUp/AgoraHandsUp.podspec', :subspecs => ['OC']

  # if you use swift project, you just only change 'OC' to 'Swift'
  pod 'AgoraActionProcess', :path => 'AgoraEduSDK/Modules/AgoraActionProcess/AgoraActionProcess.podspec', :subspecs => ['OC']
end

workspace 'AgoraEducation.xcworkspace'

target 'AgoraEducation' do
  use_frameworks!
  
  pod "AFNetworking", "4.0.1"
  pod 'OpenSSL-Universal', '1.0.2.17'
  
  sourcePod
  
end
