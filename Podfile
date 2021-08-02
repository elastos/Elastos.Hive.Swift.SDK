# Uncomment the next line to define a global platform for your project
def import_pods
  #pod 'Swifter', '1.5.0'
  pod 'Alamofire', '~> 5.0'
  pod 'PromiseKit'
  pod 'ElastosDIDSDK', '~> 2.1.0'

  pod 'BlueRSA', '~> 1.0'
  pod 'LoggerAPI', '~> 1.7'
  pod 'KituraContracts', '~> 1.1'
  pod 'BlueCryptor', '~> 1.0'
  pod 'ReadWriteLock', '~> 1.0'
  pod 'ObjectMapper'
  pod 'AwaitKit'
  pod 'SwiftyJSON'

end


target :ElastosHiveSDK do
use_frameworks!
  platform :ios, '11.0'
  import_pods
  target 'ElastosHiveSDKTests' do
    inherit! :search_paths
    import_pods
  end
end


