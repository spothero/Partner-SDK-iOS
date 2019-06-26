//
//  AccessibilityStrings.swift
//  Pods
//
//  Created by Husein Kareem on 7/13/16.
//
//

import Foundation

enum AccessibilityStrings {
    static let MapView = NSLocalizedString("Displays parking spots",
                                           comment: "Accessibility label for map view")
    static let SearchBar = NSLocalizedString("Parking spots",
                                             comment: "Accessibility label for search bar")
    static let PredictionTableView = NSLocalizedString("Place suggestions",
                                                       comment: "Accessibility label for table that shows place predictions from google maps")
    static let Address = NSLocalizedString("Address for place",
                                           comment: "Accessibility label for address label of place")
    static let City = NSLocalizedString("City for place",
                                        comment: "Accessibility label for city label of place")
    static let SpotHero = NSLocalizedString("SpotHero",
                                            comment: "SpotHero")
    static let ClearText = NSLocalizedString("Clear text",
                                             comment: "Accessibility label for the clear text button on the search bar field")
    static let TimeSelectionView = NSLocalizedString("Time of reservation",
                                                     comment: "Accessibility label for time selection view")
    static let StartsTimeSelectionView = NSLocalizedString("Start time reservation",
                                                           comment: "Accessibility label for start time selection view")
    static let EndsTimeSelectionView = NSLocalizedString("End time reservation",
                                                         comment: "Accessibility label for end time selection view")
    static let StartDateLabel = NSLocalizedString("Reservation start date",
                                                  comment: "Label that shows your reservation's start date")
    static let EndDateLabel = NSLocalizedString("Reservation end date",
                                                comment: "Label that shows your reservation's end date")
    static let StartTimeTextField = NSLocalizedString("Reservation start time",
                                                      comment: "Accessibility label for start time")
    static let EndTimeTextField = NSLocalizedString("Reservation end time",
                                                    comment: "Accessibility label for end time")
    static let CollapsedSearchBarView = NSLocalizedString("Reservation's length",
                                                          comment: "Accessibility label for collapsed search bar view")
    static let SpotCards = NSLocalizedString("info for parking spot",
                                             comment: "Accessibility label for spot cards collection view")
    static let CheckoutScreen = NSLocalizedString("Entering checkout infomation",
                                                  comment: "Accessibility label for checkout view")
    static let StartDatePicker = NSLocalizedString("Start date for reservation",
                                                   comment: "Accessibility label for start date picker")
    static let EndDatePicker = NSLocalizedString("End date for reservation",
                                                 comment: "Accessibility label for end date picker")
    static let CardImage = NSLocalizedString("Credit card logo",
                                             comment: "Accessibility string for credit card image")
}
