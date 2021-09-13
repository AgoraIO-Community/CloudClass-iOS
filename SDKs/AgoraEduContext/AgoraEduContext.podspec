Pod::Spec.new do |s|
  s.name             = 'AgoraEduContext'
  s.version          = '1.0.0'
  s.summary          = 'A short description of AgoraEduContext.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/603722906@qq.com/AgoraEduContext'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '603722906@qq.com' => 'sirusheng@agora.io' }
  s.source           = { :git => 'https://github.com/603722906@qq.com/AgoraEduContext.git', :tag => s.version.to_s }

  s.platform     = :ios
  s.ios.deployment_target = '10.0'

  s.source_files  = "AgoraEduContext/**/*.{swift,h,m}"
  s.public_header_files = [
    "AgoraEduContext/**/*.h", 
  ]

  s.dependency "AgoraUIBaseViews"
  s.dependency "AgoraExtApp"
  s.dependency "AgoraWidget"
  s.xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }

  s.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4']
end
