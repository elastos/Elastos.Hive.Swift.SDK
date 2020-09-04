# Uncomment the next line to define a global platform for your project
def import_pods
  pod 'Swifter', '~> 1.4.6'
  pod 'Alamofire'
  pod 'PromiseKit'
  pod 'ElastosDIDSDK', '1.0'
end



target :ElastosHiveSDK do
use_frameworks!
  platform :ios, '11.0'
  import_pods
  target 'ElastosHiveSDKTests' do
    inherit! :search_paths
    import_pods
  end

  target 'TestHost' do
    inherit! :search_paths
    import_pods
  end
end

  target :ElastosHiveSDK_macOS do
  platform :osx, '10.10'
  use_frameworks!
  pod 'Swifter', '~> 1.4.6'
  pod 'Alamofire'
  pod 'PromiseKit'
end

