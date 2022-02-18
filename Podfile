# Uncomment the next line to define a global platform for your project
def import_pods
  #pod 'Swifter', '1.5.0'
  pod 'Alamofire', '~> 5.0'
  pod 'PromiseKit'
  pod 'ElastosDIDSDK', '~> 2.2.1'

  pod 'ReadWriteLock', '~> 1.0'
  pod 'ObjectMapper'
  pod 'SwiftyJSON'
  pod 'AwaitKit', '~> 5.2.0'

end

workspace 'ElastosHiveSDK.xcworkspace'
xcodeproj 'ElastosHiveSDK.xcodeproj' 
xcodeproj 'Example/Examples-iOS/HiveExamples.xcodeproj'

target :ElastosHiveSDK do
xcodeproj 'ElastosHiveSDK' 
use_frameworks!
  platform :ios, '11.0'
  import_pods
  target 'ElastosHiveSDKTests' do
    inherit! :search_paths
    import_pods
    pod 'BlueRSA', '~> 1.0'
    pod 'KituraContracts', '~> 1.1'
    pod 'LoggerAPI', '~> 1.7'
    pod 'BlueCryptor', '~> 1.0'

  end
end


target :"HiveExamples" do
xcodeproj 'Example/Examples-iOS/HiveExamples'
    #source 'https://github.com/CocoaPods/Specs.git'
    platform :ios, '11.0'
    use_frameworks!
    import_pods

  pod 'CYLTabBarController'
  pod 'SnapKit'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'SVProgressHUD'
  pod 'SwiftyJSON'
  pod 'BlueRSA', '~> 1.0'
  pod 'KituraContracts', '~> 1.1'
  pod 'LoggerAPI', '~> 1.7'
  pod 'BlueCryptor', '~> 1.0'

end
