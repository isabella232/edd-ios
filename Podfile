source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!

platform :ios, '10.0'

target 'Easy Digital Downloads' do
  pod 'Alamofire', '~> 3.5'
  pod 'AlamofireNetworkActivityIndicator', '~> 1.0'
  pod 'BEMSimpleLineGraph'
  pod 'CocoaLumberjack/Swift'
  pod 'MCDateExtensions', :git => 'https://github.com/mirego/MCDateExtensions.git'
  pod 'MZFormSheetPresentationController', '~> 2.4'
  pod 'SSKeychain'
  pod 'SVProgressHUD'
  pod 'SwiftyJSON', '~> 2.3'
  pod 'TTTAttributedLabel'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '2.3'
    end
  end
end