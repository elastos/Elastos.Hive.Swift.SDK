# Uncomment the next line to define a global platform for your project
def import_pods
  pod 'Swifter'
  pod 'Alamofire'
  pod 'PromiseKit'
 # pod 'ElastosDIDSDK', '1.1'

  pod 'BlueRSA', '~> 1.0'
  pod 'LoggerAPI', '~> 1.7'
  pod 'KituraContracts', '~> 1.1'
  pod 'BlueCryptor', '~> 1.0'
end



target :ElastosHiveSDK do

  use_frameworks!
  platform :ios, '11.0'
  import_pods
#  target 'ElastosHiveSDKTests' do
#    inherit! :search_paths
#    import_pods
#  end
#
#  target 'TestHost' do
#    inherit! :search_paths
#    import_pods
#  end
end

target :ElastosHiveSDKTests do

  use_frameworks!
  platform :ios, '11.0'
  import_pods
#  target 'ElastosHiveSDKTests' do
#    inherit! :search_paths
#    import_pods
#  end

#  target 'TestHost' do
#    inherit! :search_paths
#    import_pods
#  end
end

target :TestHost do

  use_frameworks!
  platform :ios, '11.0'
  import_pods

end


target :ElastosHiveSDK_macOS do
  platform :osx, '10.10'
  use_frameworks!
  pod 'Swifter'
  pod 'Alamofire'
  pod 'PromiseKit'
end

