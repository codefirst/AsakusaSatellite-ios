platform :ios, '8.0'
use_frameworks!


def common
    pod 'AsakusaSatellite'
end

link_with 'AsakusaSatellite'
common
pod 'NorthLayout'
pod 'HanekeSwift'
pod 'TUSafariActivity', '~> 1.0'
pod 'Fabric'
pod 'Crashlytics'

target 'ShareExtension', :exclusive => true do
    common
    pod 'AppGroup', :podspec => 'Pods/CocoaPodsAppGroup/AppGroup.podspec.json'
end

target 'Specs', :exclusive => true do
    link_with 'AsakusaSatelliteTests'
    common
    pod 'Quick'
    pod 'Nimble'
end

plugin 'cocoapods-app_group'
