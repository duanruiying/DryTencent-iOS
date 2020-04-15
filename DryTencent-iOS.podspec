#
# Be sure to run `pod lib lint DryTencent-iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#
# 提交仓库:
# pod spec lint DryTencent-iOS.podspec --allow-warnings --use-libraries
# pod trunk push DryTencent-iOS.podspec --allow-warnings --use-libraries
#

Pod::Spec.new do |s|
  
  # Git
  s.name        = 'DryTencent-iOS'
  s.version     = '1.0.0'
  s.summary     = 'DryTencent-iOS'
  s.homepage    = 'https://github.com/duanruiying/DryTencent-iOS'
  s.license     = { :type => 'MIT', :file => 'LICENSE' }
  s.author      = { 'duanruiying' => '2237840768@qq.com' }
  s.source      = { :git => 'https://github.com/duanruiying/DryTencent-iOS.git', :tag => s.version.to_s }
  s.description = <<-DESC
  TODO: iOS简化腾讯集成(授权、获取用户信息、分享).
  DESC
  
  # User
  #s.swift_version          = '5.0'
  s.ios.deployment_target   = '10.0'
  s.requires_arc            = true
  s.user_target_xcconfig    = {'OTHER_LDFLAGS' => ['-w']}
  
  # Pod
  s.static_framework        = true
  s.pod_target_xcconfig     = {'OTHER_LDFLAGS' => ['-w']}
  
  # Code
  s.source_files        = 'DryTencent-iOS/Classes/Code/**/*'
  s.public_header_files = 'DryTencent-iOS/Classes/Code/Public/**/*.h'
  
  # System
  s.libraries  = 'z', 'c++', 'iconv', 'sqlite3'
  s.frameworks = 'UIKit', 'Foundation', 'SystemConfiguration', 'Security', 'CoreGraphics', 'CoreTelephony', 'WebKit'
  
  # ThirdParty
  #s.vendored_libraries  = ''
  s.vendored_frameworks = 'DryTencent-iOS/Classes/Frameworks/*.framework'
  #s.dependency 'AlipaySDK-iOS'
  
end
