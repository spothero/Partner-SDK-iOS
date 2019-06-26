# frozen_string_literal: true

Pod::Spec.new do |s|
  s.name                  = 'SpotHero_iOS_Partner_SDK'
  # s.module_name           = 'SpotHero_iOS_Partner_SDK'
  s.ios.deployment_target = '10.0'
  s.version               = '2.3.0'
  s.summary               = 'An SDK for simple integration with SpotHero.'
  s.license               = 'LICENSE.md'
  s.description           = <<~DESC
    An SDK that allows your users to book SpotHero parking directly from within your app.
  DESC
  s.homepage              = 'https://github.com/spothero/Partner-SDK-iOS'
  s.author                = { 'SpotHero iOS' => 'ios@spothero.com' }
  s.source                = { git: 'https://github.com/spothero/Partner-SDK-iOS.git', tag: s.version.to_s }
  s.social_media_url      = 'https://twitter.com/SpotHero'
  s.source_files          = 'PartnerSDK/PartnerSDK/Classes/**/*.swift'

  s.resources             = 'PartnerSDK/PartnerSDK/Assets/**/*.{png,storyboard,lproj,xcassets,xib,otf}'

  s.screenshots           = 'https://github.com/spothero/Partner-SDK-iOS/blob/master/readme_img/stock.png'

  s.frameworks            = 'UIKit', 'MapKit', 'CoreLocation'
  s.swift_version         = '4.2'
end
