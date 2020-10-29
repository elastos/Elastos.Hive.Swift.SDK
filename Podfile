# Uncomment the next line to define a global platform for your project
def import_pods
  pod 'Swifter', '1.5.0'
  pod 'Alamofire'
  pod 'PromiseKit'
  #pod 'ElastosDIDSDK', '1.1'

  pod 'BlueRSA', '~> 1.0'
  pod 'LoggerAPI', '~> 1.7'
  pod 'KituraContracts', '~> 1.1'
  pod 'BlueCryptor', '~> 1.0'
end



target :ElastosHiveSDK do
use_frameworks!
  platform :ios, '11.0'
  import_pods
  target 'ElastosHiveSDKTest' do
    inherit! :complete
    import_pods
  end
end

target :ElastosHiveSDK_macOS do
  platform :osx, '10.10'
  use_frameworks!
  pod 'Swifter', '1.5.0'
  pod 'Alamofire'
  pod 'PromiseKit'
end

