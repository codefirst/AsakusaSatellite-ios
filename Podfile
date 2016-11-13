platform :ios, '9.0'
use_frameworks!


target 'AsakusaSatellite' do
  pod 'AsakusaSatellite'
  pod 'NorthLayout'
  pod '※ikemen'
  pod 'HanekeSwift', git: 'https://github.com/Haneke/HanekeSwift', branch: 'feature/swift-3'
  pod 'TUSafariActivity', '~> 1.0'
  pod 'Fabric'
  pod 'Crashlytics'
  
  target 'AsakusaSatelliteTests' do
    inherit! :search_paths
    pod 'Quick'
    pod 'Nimble'
  end
end

target 'ShareExtension' do
  pod 'AsakusaSatellite'
end

plugin 'cocoapods-app_group'
