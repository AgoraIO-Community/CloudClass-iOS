Pod::Spec.new do |s|
    s.name             = 'ChatWidget'
    s.version          = '0.1.0'
    s.summary          = 'CloudClass Chat Widget'
    s.description      = <<-DESC
        ‘灵动课堂聊天插件.’
    DESC
    s.homepage = 'https://www.easemob.com'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'easemob' => 'dev@easemob.com' }
    s.source           = { :git => 'https://XXX/.git', :tag => s.version.to_s }
    s.frameworks = 'UIKit'
    s.libraries = 'stdc++'
    s.ios.deployment_target = '9.0'
    
    s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES','EXCLUDED_ARCHS[sdk=iphonesimulator*]'=>'i386,arm64','VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
    
    s.subspec 'BINARY' do |binary|
      binary.resources = 'ChatWidget/ChatWidget.bundle'
      binary.source_files = 'ChatWidget/**/*.{h,m,strings}'
      binary.public_header_files = [
        'ChatWidget/Main/ChatWidget.h',
      ]

      binary.dependency 'Masonry'
      binary.dependency 'HyphenateChat'
      binary.dependency 'SDWebImage'
      binary.dependency 'WHToast'
      binary.vendored_frameworks = "../Products/Libs/AgoraWidget.framewrok"
      binary.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => ['$(SRCROOT)/../../Products/Libs/'] }
    end
    
    s.subspec 'SOURCE' do |source|
      source.dependency 'Masonry'
      source.dependency 'HyphenateChat'
      source.dependency 'SDWebImage'
      source.dependency 'WHToast'
      source.dependency "AgoraWidget"
      source.resources = 'ChatWidget/ChatWidget.bundle'
      source.source_files = 'ChatWidget/**/*.{h,m,strings}'
      source.public_header_files = [
        'ChatWidget/Main/ChatWidget.h',
      ]
    end

    s.default_subspec = 'SOURCE'
end
