
Pod::Spec.new do |s|
  s.name             = 'AgoraEduSDK'
  s.version          = '1.1.0'
  s.summary          = 'Agora Education SDK'
  s.description      = <<-DESC
  AgoraEduSDK includes the information management in the room, and also includes three educational scenarios: 'One to One', 'Small Classroom' and 'Lecture Hall'. You can quickly build an education app through the AgoraEduSDK.
                       DESC

  s.homepage         = 'https://docs.agora.io/en/agora-class/landing-page?platform=iOS'
  s.license          = { "type" => "Copyright", "text" => "Copyright 2020 agora.io. All rights reserved.\n" }
  s.author           = { "Agora Lab" => "developer@agora.io" }
  s.source           = { :http => 'https://download.agora.io/sdk/release/AgoraEduSDK-1.1.0.zip' }

  s.platform = :ios
  s.ios.deployment_target = '10.0'
  
  s.static_framework = true

  s.dependency "AgoraRtm_iOS", "1.4.6"
  s.dependency "AgoraRtcEngine_Special_iOS", "2.9.107.136"
  s.dependency "AFNetworking", "4.0.1"
  s.dependency "Whiteboard", "2.13.19-beta9"
  s.dependency "CocoaLumberjack", "3.6.1"
  s.dependency "AliyunOSSiOS", "2.10.8"
  s.dependency "Protobuf"
  
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  s.default_subspec = 'All'

  s.subspec 'All' do |fwSpec|
    fwSpec.vendored_frameworks = [
      "Frameworks/*.framework"
    ]
    fwSpec.resource = "Frameworks/AgoraEduSDK.bundle"
  end

  s.subspec 'Core' do |cSpec|
    cSpec.vendored_frameworks = [
      "Frameworks/AgoraActionProcess.framework",
      "Frameworks/AgoraEduContext.framework",
      "Frameworks/AgoraEduSDK.framework",
      "Frameworks/AgoraExtApp.framework",
      "Frameworks/AgoraReport.framework",
      "Frameworks/AgoraWhiteBoard.framework",
      "Frameworks/AgoraWidget.framework",
      "Frameworks/EduSDK.framework",
      "Frameworks/AgoraLog.framework",
    ]
    cSpec.resource = "Frameworks/AgoraEduSDK.bundle"
  end
end