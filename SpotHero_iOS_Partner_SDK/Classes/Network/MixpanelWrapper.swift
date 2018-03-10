//
//  MixpanelWrapper.swift
//  Pods
//
//  Created by SpotHeroMatt on 10/10/16.
//
//

import Foundation

enum MixpanelKey: String {
    case
    price = "Price",
    spotID = "Spot ID",
    spotHeroCity = "SpotHero City",
    reservationLength = "Reservation length",
    distance = "Distance",
    distanceFromSearchCenter = "Distance from Search Center",
    paymentType = "Payment Type",
    requiredLicensePlate = "Required License Plate",
    requiredPhoneNumber = "Required Phone Number",
    emailAddress = "Email address",
    phoneNumber = "Phone Number",
    timeFromReservationStart = "Time From Reservation Start",
    tappedPin = "Tapped Pin",
    viewingMethod = "Viewing Method",
    spotAddress = "Spot Address",
    searchQuery = "Search Query",
    tappedRedoSearch = "Tapped Redo Search",
    optimalZoom = "Optimal Zoom",
    resultsWithinOptimalZoom = "Results within optimal zoom",
    searchType = "Search Type",
    token,
    event,
    properties,
    tappedBookAnother = "Tapped book another",
    tappedDone = "Tapped done",
    sdkClosed = "SDK Closed",
    mediaSource = "media_source"
}

enum MixpanelEvent: String {
    case
    sdkOpened = "SDK Opened",
    sdkClosed = "SDK Closed",
    userPurchased = "Purchased",
    postPurchase = "Post Purchase",
    viewedSearchResultsScreen = "Viewed Search Results",
    viewedNoResultsFoundModal = "Viewed No Results Found Modal",
    tappedSpotPin = "Tapped Spot Pin",
    userSearched = "Searched",
    viewedCheckout = "Entered Checkout Flow",
    viewedSpotDetails = "Product Details Page"
}

struct MixpanelWrapper {
    private static let baseUrlString = "https://api.mixpanel.com/track/"
    
    static func track(_ event: MixpanelEvent, properties: [MixpanelKey: Any] = [:]) {
        guard !TestingHelper.isTesting() else {
            return
        }
        
        var mutableProperties = properties
        mutableProperties[MixpanelKey.token] = APIKeyConfig.sharedInstance.mixpanelApiKey
        mutableProperties[MixpanelKey.mediaSource] = "iOS SDK"
        var stringDictionary = [String: Any]()
        
        for (key, value) in mutableProperties {
            stringDictionary [key.rawValue] = value
        }
        
        let eventDictionary: [String: Any] = [MixpanelKey.event.rawValue: event.rawValue, MixpanelKey.properties.rawValue: stringDictionary]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: eventDictionary)
            let base64 = jsonData.base64EncodedString(options: [])
            var urlComponents = URLComponents(string: baseUrlString)
            urlComponents?.query = "data=\(base64)"
            if let url = urlComponents?.url {
                URLSession.shared.dataTask(with: url, completionHandler: {
                    data, _, error in
                    if let error = error {
                        print(error)
                    } else {
                        if let data = data {
                            print(data)
                        }
                        print("Mix Panel event: \(event) \nProperties: \(properties)")
                    }
                }).resume()
            } else {
                assertionFailure("Cannot create url")
            }
        } catch {
            assertionFailure("Invalid JSON")
        }
    }
}
