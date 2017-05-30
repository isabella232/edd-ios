source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

platform :ios, '10.0'

abstract_target 'EDD' do
  target 'Easy Digital Downloads' do
    pod 'Alamofire', '~> 4.4'
    pod 'CocoaLumberjack/Swift'
    pod 'MCDateExtensions', :git => 'https://github.com/mirego/MCDateExtensions.git'
    pod 'SSKeychain'
    pod 'SwiftyJSON'
    pod 'HanekeSwift'
    pod 'AlamofireNetworkActivityIndicator', '~> 2.0'
    pod 'BEMSimpleLineGraph'
    pod 'AlamofireImage', '~> 3.1'
  end

  target 'Today' do
    pod 'Alamofire', '~> 4.4'
    pod 'CocoaLumberjack/Swift'
    pod 'MCDateExtensions', :git => 'https://github.com/mirego/MCDateExtensions.git'
    pod 'SSKeychain'
    pod 'SwiftyJSON'
    pod 'HanekeSwift'
  end

  target 'Watch Extension' do
    platform :watchos, ‘3.0’
    pod 'Alamofire', '~> 4.4'
    pod 'SwiftyJSON'
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
