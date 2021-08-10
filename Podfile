# Uncomment the next line to define a global platform for your project
# source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
inhibit_all_warnings!

def sourcePod
  pod 'AgoraEduSDK', :path => 'AgoraEduSDK/Modules/AgoraEduSDK/AgoraEduSDK.podspec'
  
  pod 'AgoraLog', :path => 'AgoraEduSDK/Modules/AgoraLog/AgoraLog.podspec'
  pod 'EduSDK', :path => 'AgoraEduSDK/Modules/EduSDK/EduSDK.podspec'
  pod 'AgoraWhiteBoard', :path => 'AgoraEduSDK/Modules/AgoraWhiteBoard/AgoraWhiteBoard.podspec'

  pod 'AgoraReport', :path => 'AgoraEduSDK/Modules/AgoraReport/AgoraReport.podspec'
  
  pod 'AgoraUIBaseViews', :path => 'AgoraEduSDK/Modules/AgoraUIBaseViews/AgoraUIBaseViews.podspec'
  pod 'AgoraUIEduAppViews', :path => 'AgoraEduSDK/Modules/AgoraUIEduAppViews/AgoraUIEduAppViews.podspec', :subspecs => ['SOURCE']
  pod 'AgoraUIEduBaseViews', :path => 'AgoraEduSDK/Modules/AgoraUIEduBaseViews/AgoraUIEduBaseViews.podspec', :subspecs => ['SOURCE']

  pod 'AgoraExtApp', :path => 'AgoraEduSDK/Modules/AgoraExtApp/AgoraExtApp.podspec'
  pod 'AgoraWidget', :path => 'AgoraEduSDK/Modules/AgoraWidget/AgoraWidget.podspec'
  pod 'AgoraEduContext', :path => 'AgoraEduSDK/Modules/AgoraEduContext/AgoraEduContext.podspec'
  pod 'AgoraEduExtApp', :path => 'AgoraEduSDK/Modules/AgoraEduExtApp/AgoraEduExtApp.podspec'
  
  # if you use swift project, you just only change 'OC' to 'Swift'
  pod 'AgoraActionProcess', :path => 'AgoraEduSDK/Modules/AgoraActionProcess/AgoraActionProcess.podspec', :subspecs => ['OC']

  pod 'Protobuf'

  pod 'ChatWidget', :path => 'AgoraEduSDK/Modules/ChatWidget/ChatWidget.podspec'

end

def binaryPod
  pod 'AgoraEduSDK', :path => 'AgoraEduSDK/AgoraEduSDK.podspec'
  pod 'ChatWidget', :path => 'AgoraEduSDK/Modules/ChatWidget/ChatWidget.podspec', :subspecs => ['BINARY']
end

def uiSourcePod
  pod 'AgoraEduSDK', :path => 'AgoraEduSDK/AgoraEduSDK.podspec', :subspecs => ['Core']  

  pod 'AgoraUIBaseViews', :path => 'AgoraEduSDK/Modules/AgoraUIBaseViews/AgoraUIBaseViews.podspec'
  pod 'AgoraUIEduBaseViews', :path => 'AgoraEduSDK/Modules/AgoraUIEduBaseViews/AgoraUIEduBaseViews.podspec', :subspecs => ['BINARY']
  pod 'AgoraUIEduAppViews', :path => 'AgoraEduSDK/Modules/AgoraUIEduAppViews/AgoraUIEduAppViews.podspec', :subspecs => ['BINARY']
end

workspace 'AgoraEducation.xcworkspace'
install! 'cocoapods', :deterministic_uuids => false, :warn_for_unused_master_specs_repo => false

target 'AgoraEducation' do
  use_frameworks!
  
  pod "AFNetworking", "4.0.1"
  pod 'OpenSSL-Universal', '1.0.2.17'

  sourcePod
  #binaryPod
  #uiSourcePod
end
