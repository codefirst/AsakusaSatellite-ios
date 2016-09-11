platform :ios, '8.0'
use_frameworks!


target 'AsakusaSatellite' do
  pod 'AsakusaSatellite'
  pod 'NorthLayout'
  pod 'HanekeSwift'
  pod 'TUSafariActivity', '~> 1.0'
  pod 'Fabric'
  pod 'Crashlytics'
  plugin 'cocoapods-app_group', targets: ['AsakusaSatellite']
  
  target 'ShareExtension' do
    inherit! :search_paths
  end
  
  target 'AsakusaSatelliteTests' do
    inherit! :search_paths
    pod 'Quick'
    pod 'Nimble'
  end
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
    end
  end
end

