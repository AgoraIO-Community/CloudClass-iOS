# Uncomment the next line to define a global platform for your project
# source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
inhibit_all_warnings!

workspace 'AgoraEducation.xcworkspace'
install! 'cocoapods', :deterministic_uuids => false, :warn_for_unused_master_specs_repo => false

target 'AgoraEducation' do
  use_frameworks!
  
  pod "AFNetworking", "4.0.1"
  pod 'OpenSSL-Universal', '1.0.2.17'

# AgoraClassroomSDK
  pod "AgoraClassroomSDK/Core"
  
#  UIKIT
  pod 'AgoraUIBaseViews', :path => 'AgoraEduSDK/Modules/AgoraUIBaseViews/AgoraUIBaseViews.podspec'
  pod 'AgoraUIEduAppViews', :path => 'AgoraEduSDK/Modules/AgoraUIEduAppViews/AgoraUIEduAppViews.podspec', :subspecs => ['BINARY']
  pod 'AgoraUIEduBaseViews', :path => 'AgoraEduSDK/Modules/AgoraUIEduBaseViews/AgoraUIEduBaseViews.podspec', :subspecs => ['BINARY']
end
