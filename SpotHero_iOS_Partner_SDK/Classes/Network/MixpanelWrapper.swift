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
    Price,
    SpotID = "Spot ID",
    SpotHeroCity = "SpotHero City",
    ReservationLength = "Reservation length",
    Distance,
    DistanceFromSearchCenter = "Distance from Search Center",
    PaymentType = "Payment Type",
    RequiredLicensePlate = "Required License Plate",
    RequiredPhoneNumber = "Required Phone Number",
    EmailAddress = "Email address",
    PhoneNumber = "Phone Number",
    TimeFromReservationStart = "Time From Reservation Start",
    TappedPin = "Tapped Pin",
    ViewingMethod = "Viewing Method",
    SpotAddress = "Spot Address",
    SearchQuery = "Search Query",
    TappedRedoSearch = "Tapped Redo Search",
    OptimalZoom = "Optimal Zoom",
    ResultsWithinOptimalZoom = "Results within optimal zoom",
    SearchType = "Search Type",
    Token = "token",
    Event = "event",
    Properties = "properties",
    TappedBookAnother = "Tapped book another",
    TappedDone = "Tapped done",
    SDKClosed = "SDK Closed"
}

enum MixpanelEvent: String {
    case
    SDKOpened = "SDK Opened",
    SDKClosed = "SDK Closed",
    UserPurchased = "User Purchased",
    PostPurchase = "Post Purchase",
    ViewedSearchResultsScreen = "Viewed Search Results Screen",
    ViewedNoResultsFoundModal = "Viewed No Results Found Modal",
    TappedSpotPin = "Tapped Spot Pin",
    UserSearched = "User Searched"
}

struct MixpanelWrapper {
    private static let baseUrlString = "https://api.mixpanel.com/track/"
    
    static func track(_ event: MixpanelEvent, properties: [MixpanelKey: Any] = [:]) {
        guard !TestingHelper.isTesting() else {
            return
        }
        
        var mutableProperties = properties
        mutableProperties[MixpanelKey.Token] = APIKeyConfig.sharedInstance.mixpanelApiKey
        var stringDictionary = [String: Any]()
        
        for (key, value) in mutableProperties {
            stringDictionary [key.rawValue] = value
        }
        
        let eventDictionary: [String: Any] = [MixpanelKey.Event.rawValue: event.rawValue, MixpanelKey.Properties.rawValue: stringDictionary]
        
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
