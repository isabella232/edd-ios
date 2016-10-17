source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

platform :ios, '10.0'

abstract_target 'EDD' do
  pod 'Alamofire', '~> 3.5'
  pod 'CocoaLumberjack/Swift'
  pod 'MCDateExtensions', :git => 'https://github.com/mirego/MCDateExtensions.git'
  pod 'SSKeychain'
  pod 'SwiftyJSON', '~> 2.3'
  pod 'HanekeSwift', :git => 'https://github.com/Haneke/HanekeSwift.git', :branch => 'feature/swift-2.3'

  target 'Easy Digital Downloads' do
    pod 'AlamofireNetworkActivityIndicator', '= 1.1.0'
    pod 'BEMSimpleLineGraph'
    pod 'AlamofireImage', '= 2.5.0'
  end

  target 'Today'
  target 'Watch Extension' do
    platform :watchos, ‘3.0’
    pod 'Alamofire', '~> 3.5'
  end
end