platform :ios, '8.0'
use_frameworks!

link_with 'AsakusaSatellite'

pod 'AsakusaSatellite', :git => 'https://github.com/codefirst/AsakusaSatelliteSwiftClient.git', :branch => 'xcode7'
pod 'Alamofire', :git => 'https://github.com/Alamofire/Alamofire.git', :branch => 'swift-2.0'
pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git', :branch => 'xcode7'
pod 'Socket.IO-Client-Swift', :git => 'https://github.com/socketio/socket.io-client-swift.git', :branch => 'swift-2'
pod 'UTIKit', :git => 'https://github.com/banjun/UTIKit.git', :branch => 'xcode7'

pod 'HanekeSwift', :git => 'https://github.com/meteochu/HanekeSwift.git', :branch => 'swift-2.0'
pod 'TUSafariActivity', '~> 1.0'


target 'Specs' do
    link_with 'AsakusaSatelliteTests'
    pod 'Quick'
    pod 'Nimble'
end
