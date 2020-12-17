#
#  Be sure to run `pod spec lint hive.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = 'ElastosHiveSDK'
  s.version      = '2.0.7'
  s.summary      = 'Elastos Hive iOS SDK Distribution.'
  s.swift_version = '4.2'
  s.description  = 'Elastos hive ios sdk framework distribution.'
  s.homepage     = 'https://www.elastos.org'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'hive-dev' => 'support@elastos.org' }
  s.platform     = :ios, '11.0'
  s.ios.deployment_target = '11.0'
  s.source = {:git => 'https://github.com/elastos/Elastos.NET.Hive.Swift.SDK.git', :tag => s.version}
  s.source_files = 'ElastosHiveSDK/**/*.swift'
  s.dependency 'Alamofire','~> 5.0'
  s.dependency 'PromiseKit','~> 6.9'
  s.dependency 'ElastosDIDSDK', '~> 1.5'
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

end
