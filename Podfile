# Uncomment the next line to define a global platform for your project
def import_pods
  pod 'Swifter', '~> 1.4.6'
  pod 'Alamofire'
  pod 'PromiseKit'
end

use_frameworks!

workspace 'ElastosHiveSDK'

target :ElastosHiveSDK do
project 'ElastosHiveSDK.xcodeproj'

  platform :ios, '9.0'
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
  import_pods
end


#####################example
target 'ElastosHiveSDKExample' do
  project 'ElastosHiveSDKExample/ElastosHiveSDKExample.xcodeproj'
  import_pods
end
