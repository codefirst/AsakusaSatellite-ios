platform :ios, '8.0'
use_frameworks!

link_with 'AsakusaSatellite'

pod 'AsakusaSatellite', :git => 'https://github.com/codefirst/AsakusaSatelliteSwiftClient.git', :branch => 'xcode7'
pod 'UTIKit', :git => 'https://github.com/cockscomb/UTIKit.git', :branch => 'swift2'

pod 'NorthLayout'
pod 'HanekeSwift', :git => 'https://github.com/Haneke/HanekeSwift.git', :tag => 'v0.10.0'
pod 'TUSafariActivity', '~> 1.0'


target 'Specs' do
    link_with 'AsakusaSatelliteTests'
    pod 'Quick'
    pod 'Nimble', '2.0.0-rc.3'
end
