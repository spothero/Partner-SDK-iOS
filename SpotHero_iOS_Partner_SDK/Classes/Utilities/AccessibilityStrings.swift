//
//  AccessibilityStrings.swift
//  Pods
//
//  Created by Husein Kareem on 7/13/16.
//
//

import Foundation

enum AccessibilityStrings {
    static let MapView = NSLocalizedString("Map for displaying parking spots",
                                           comment: "Accessibility label for map view")
    static let SearchBar = NSLocalizedString("Search for parking spots",
                                             comment: "Accessibility label for search bar")
    static let PredictionTableView = NSLocalizedString("Table of place suggestions from Google",
                                                       comment: "Accessibility label for table that shows place predictions from google maps")
    static let Address = NSLocalizedString("The address of a place",
                                           comment: "Accessibility label for address label of place")
    static let City = NSLocalizedString("The city of a place",
                                        comment: "Accessibility label for city label of place")
    static let SpotHero = NSLocalizedString("SpotHero",
                                            comment: "SpotHero")
    static let ClearText = NSLocalizedString("Clear text",
                                             comment: "Accessibility label for the clear text button on the search bar field")
    static let TimeSelectionView = NSLocalizedString("Select the time of your reservation",
                                                     comment: "Accessibility label for time selection view")
    static let StartsTimeSelectionView = NSLocalizedString("Select the start time of your reservation",
                                                           comment: "Accessibility label for start time selection view")
    static let EndsTimeSelectionView = NSLocalizedString("Select the end time of your reservation",
                                                         comment: "Accessibility label for end time selection view")
    static let StartDateLabel = NSLocalizedString("Shows your reservation's start date",
                                                  comment: "Label that shows your reservation's start date")
    static let EndDateLabel = NSLocalizedString("Shows your reservation's end date",
                                                comment: "Label that shows your reservation's end date")
    static let StartTimeLabel = NSLocalizedString("Shows your reservation's start time",
                                                  comment: "Accessibility label for start time")
    static let EndTimeLabel = NSLocalizedString("Shows your reservation's end time",
                                                comment: "Accessibility label for end time")
    static let CollapsedSearchBarView = NSLocalizedString("Shows you reservation's length",
                                                          comment: "Accessibility label for collapsed search bar view")
    static let SpotCards = NSLocalizedString("Shows info about a certain parking spot",
                                             comment: "Accessibility label for spot cards collection view")
    static let ConfirmationScreen = NSLocalizedString("Confimation screen. Seen after a spot is purchased",
                                                     comment: "Confimation screen. Seen after a spot is purchased")
    static let CheckoutScreen = NSLocalizedString("Screen for entering checkout infomation",
                                                  comment: "Accessibility label for checkout view")
    static let StartDatePicker = NSLocalizedString("Pick a start date for your reservation",
                                              comment: "Accessibility label for start date picker")
    static let EndDatePicker = NSLocalizedString("Pick an end date for your reservation",
                                                   comment: "Accessibility label for end date picker")
    static let CardImage = NSLocalizedString("Credit card logo for type of card entered",
                                             comment: "Accessibility string for credit card image")
}
