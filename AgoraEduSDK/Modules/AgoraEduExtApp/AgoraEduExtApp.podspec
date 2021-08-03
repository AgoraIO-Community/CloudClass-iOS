#
# Be sure to run `pod lib lint AgoraEduExtApp.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AgoraEduExtApp'
  s.version          = '1.0.0'
  s.summary          = 'A short description of AgoraEduExtApp.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/603722906@qq.com/AgoraEduExtApp'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '603722906@qq.com' => 'sirusheng@agora.io' }
  s.source           = { :git => 'https://github.com/603722906@qq.com/AgoraEduExtApp.git', :tag => s.version.to_s }

  s.platform     = :ios
  s.ios.deployment_target = '10.0'

  s.source_files  = "AgoraEduExtApp/**/*.{swift,h,m}"
  s.public_header_files = [
    "AgoraEduExtApp/**/*.h", 
  ]

  s.dependency "AgoraUIBaseViews"
  s.dependency "AgoraExtApp"
  s.dependency "AgoraWidget"
  s.dependency "AgoraEduContext"
  
  s.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4']
end
