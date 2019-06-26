# frozen_string_literal: true

use_frameworks!

platform :ios, '10.0'

workspace 'PartnerSDK.xcworkspace'
project 'PartnerSDK/PartnerSDK.xcodeproj'

# Shared Pods
pod 'SwiftLint', '~> 0.29'

# SDK
target 'SpotHero_iOS_Partner_SDK' do
end

# Demo App
target 'PartnerSDKDemo' do
  pod 'SpotHero_iOS_Partner_SDK', path: './SpotHero_iOS_Partner_SDK.podspec'

  # TODO: Move into SDK target above?
  target 'PartnerSDKTests' do
    inherit! :search_paths
    pod 'VOKMockUrlProtocol', '~> 2.4.0'
  end

  target 'PartnerSDKUITests' do
    inherit! :search_paths
    pod 'VOKMockUrlProtocol', '~> 2.4.0'
    pod 'KIF', '~> 3.7.1'
  end
end
