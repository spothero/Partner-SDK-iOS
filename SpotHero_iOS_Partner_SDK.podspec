Pod::Spec.new do |s|
    s.name             = 'SpotHero_iOS_Partner_SDK'
    s.ios.deployment_target = '9.0'
    s.version          = '0.1.0'
    s.summary          = 'An SDK for simple integration with SpotHero.'
    s.license          = 'LICENSE.md'
    s.description      = <<-DESC
An SDK that allows your users to book SpotHero parking directly from within your app.
                            DESC
    s.homepage         = 'https://github.com/spothero/Partner-SDK-iOS'
    s.author           = { 'SpotHero Mobile' => 'mobile@spothero.com' }
    s.source           = { :git => 'https://github.com/spothero/Partner-SDK-iOS.git', :tag => s.version.to_s }
    s.social_media_url = 'https://twitter.com/SpotHero'
    s.source_files = 'SpotHero_iOS_Partner_SDK/Classes/**/*'

    s.screenshots     = 'https://github.com/spothero/Partner-SDK-iOS/tree/master/readme_img/stock.png'
    s.resource_bundles = {
        'SpotHero_iOS_Partner_SDK' => ['SpotHero_iOS_Partner_SDK/Assets/*.{png,storyboard,lproj,xcassets,xib}']
    }

    s.public_header_files = 'Pod/Classes/**/*.h'
    s.frameworks = 'UIKit', 'MapKit', 'CoreLocation'
end
