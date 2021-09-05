Pod::Spec.new do |spec|
  spec.name             = 'AgoraEduSDK'
  spec.version          = '1.0.1'
  spec.summary          = 'Education scene SDK'

  spec.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  spec.homepage         = 'https://github.com/603722906@qq.com/AgoraEduSDK'
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.author           = { '603722906@qq.com' => 'sirusheng@agora.io' }
  spec.source           = { :git => 'https://github.com/603722906@qq.com/AgoraEduSDK.git', :tag => spec.version.to_s }

  spec.ios.deployment_target = '10.0'
  spec.frameworks = 'AudioToolbox', 'Foundation', 'UIKit'

  spec.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4']
  
  spec.default_subspec = 'BINARY'
  
  spec.subspec 'BINARY' do |binary|
    binary.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => ['$(SRCROOT)/../Products/Libs/'] }

    binary.vendored_frameworks = [
      "Libs/*.framework"
    ]
  end

end
