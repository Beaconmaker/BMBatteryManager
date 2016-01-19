#
# Be sure to run `pod lib lint BMBatteryManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "BMBatteryManager"
  s.version          = "0.1.1"
  s.summary          = "A quick SDK to collect and report battery life of Kontakt beacons to the Kontakt cloud"

  s.description      = <<-DESC
                       DESC

  s.homepage         = "https://github.com/beaconmaker/BMBatteryManager"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "John Kueh" => "john@beaconmaker.com" }
  s.source           = { :git => "https://github.com/beaconmaker/BMBatteryManager.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/beaconmaker'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'BMBatteryManager' => ['Pod/Assets/*.png']
  }

  s.dependency 'AFNetworking', '<= 2.6.3'
  s.dependency 'KontaktSDK'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'

end