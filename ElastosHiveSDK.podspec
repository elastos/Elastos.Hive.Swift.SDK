#
#  Be sure to run `pod spec lint hive.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "ElastosHiveSDK"
  s.version      = "0.5.0"
  s.summary      = "Elastos Hive iOS SDK Distribution."
  s.swift_version = '4.2'
  s.description  = 'Elastos hive ios sdk framework distribution.'
  s.homepage     = "https://www.elastos.org"
  s.license      = { :type => "MIT", :file => "ElastosCarrier-framework/LICENSE" }
  s.author       = { "carrier-dev" => "release@elastos.org" }
  s.platform     = :ios, "9.0"
  s.ios.deployment_target = "9.0"
  s.source       = { :git=> "https://github.com/elastos/Elastos.NET.Hive.Swift.SDK/releases/download/release-v0.5.0/ElastosHive-framework.zip", :tag => s.version }
  s.vendored_frameworks = 'ElastosHive-framework/*.framework'
  s.source_files = 'ElastosHive-framework/ElastosHiveSDK.framework/**/*.h'


end
