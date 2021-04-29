#
# Be sure to run `pod lib lint AgoraBaseBinary.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AgoraBaseBinary'
  s.version          = '1.0.0'
  s.summary          = 'A short description of AgoraBaseBinary.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/603722906@qq.com/AgoraBaseBinary'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '603722906@qq.com' => 'sirusheng@agora.io' }
  s.source           = { :git => 'https://github.com/603722906@qq.com/AgoraBaseBinary.git', :tag => s.version.to_s }

  s.platform     = :ios
  s.ios.deployment_target = '10.0'
  # fix empty error
  s.dependency "AgoraUIBaseViews"
  s.module_name   = 'AgoraBaseBinary'
  s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '$(SRCROOT)/../../Frameworks' }

end


