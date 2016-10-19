Pod::Spec.new do |s|
    s.name                  = 'SpotHero_iOS_Google_Places_Wrapper'
    s.ios.deployment_target = '9.0'
    s.version               = '0.1.0'
    s.summary               = 'Google Places Wrapper'
    s.license               = 'LICENSE.md'
    s.description           = <<-DESC
A wrapper class for the Google Places API.
                            DESC
    s.homepage              = 'https://github.com/spothero/iOS-Partner-SDK'
    s.author                = { 'SpotHero Mobile' => 'mobile@spothero.com' }
    s.source                = { :git => 'https://github.com/spothero/iOS-Partner-SDK.git', :tag => s.version.to_s }
    s.social_media_url      = 'https://twitter.com/SpotHero'
    s.source_files          = 'SpotHero_iOS_Partner_SDK/Classes/*/GooglePlace*.swift', 'SpotHero_iOS_Partner_SDK/Classes/Network/JSONDictionary.swift'
    s.frameworks            = 'UIKit', 'MapKit', 'CoreLocation'
end
