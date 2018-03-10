//
//  LocalizedStrings.swift
//  Pods
//
//  Created by Husein Kareem on 7/13/16.
//
//

import Foundation

enum LocalizedStrings {
    static let Close = NSLocalizedString("Close",
                                         comment: "Close bar button title")
    static let Done = NSLocalizedString("Done",
                                        comment: "Done bar button title")
    static let PresentSDK = NSLocalizedString("Present SDK",
                                              comment: "Launch SDK button title")
    static let BookParking = NSLocalizedString("Book Parking",
                                               comment: "Book parking view title")
    static let BestMatches = NSLocalizedString("BEST MATCHES",
                                               comment: "Places Autocomplete Title")
    static let SetStartTime = NSLocalizedString("Set Start Time",
                                                comment: "Set Start Time")
    static let SetEndTime = NSLocalizedString("Set End Time",
                                              comment: "Set End Time")
    static let Address = NSLocalizedString("Address",
                                           comment: "Title for address row of checkout screen")
    static let Starts = NSLocalizedString("Starts",
                                          comment: "Title for start date row of checkout screen")
    static let Ends = NSLocalizedString("Ends",
                                        comment: "Title for end date row of checkout screen")
    static let Email = NSLocalizedString("Email",
                                         comment: "Title for Email row of checkout screen")
    static let EmailAddressPlaceHolder = NSLocalizedString("Email Address",
                                                           comment: "Placeholder for Email row of checkout screen")
    static let PhoneNumberPlaceHolder = NSLocalizedString("Phone Number",
                                                          comment: "Placeholder for Phone Number row of checkout screen")
    static let ReservationInfo = NSLocalizedString("RESERVATION INFO",
                                                   comment: "Title for reservation info section of checkout screen")
    static let PersonalInfo = NSLocalizedString("PERSONAL INFO",
                                                comment: "Title for personal info section of checkout screen")
    static let PaymentInfo = NSLocalizedString("PAYMENT INFO",
                                               comment: "Title for payment info section of checkout screen")
    static let CreditCardWarning = NSLocalizedString("A credit card is required to guarantee your reservation.",
                                                     comment: "Label explaining that a credit card is required to guarantee a reservation")
    static let CreditCard = NSLocalizedString("Credit Card",
                                              comment: "Name of credit card field")
    static let ExpirationDate = NSLocalizedString("Expiration Date",
                                                  comment: "Name of expiration date field")
    static let CVC = NSLocalizedString("CVC",
                                       comment: "Name of CVC field")
    static let FullNameErrorMessage = NSLocalizedString("Please enter a valid full name",
                                                        comment: "Error message for an invalid full name")
    static let EmailErrorMessage = NSLocalizedString("Please enter a valid email.",
                                                     comment: "Error message for an invalid email")
    static let CreditCardErrorMessage = NSLocalizedString("Please enter a valid credit card.",
                                                          comment: "Error message for an invalid credit card")
    static let NonAcceptedCreditCardErrorMessage = NSLocalizedString("Please enter a Visa, Discover, MasterCard, or American Express card.",
                                                                     //swiftlint:disable:next line_length
                                                                     comment: "Error message for a credit card that is not a Visa, Discover, MasterCard, or American Express card")
    static let InvalidDateErrorMessage = NSLocalizedString("Please enter a valid expiration date.",
                                                           comment: "Error message for an invalid expiration date")
    static let DateInThePastErrorMessage = NSLocalizedString("Please enter an expiration date in the future.",
                                                             comment: "Error message for an expiration date in the past")
    static let CVCErrorMessage = NSLocalizedString("Please enter a valid cvc.",
                                                   comment: "Error message for an invalid cvc")
    static let Visa = NSLocalizedString("VISA",
                                        comment: "A Visa Credit Card")
    static let Amex = NSLocalizedString("AMEX",
                                        comment: "An American Express Credit Card")
    static let MasterCard = NSLocalizedString("MC",
                                        comment: "A MasterCard Credit Card")
    static let Discover = NSLocalizedString("DISC",
                                        comment: "A Discover Credit Card")
    static let PaymentButtonTitleFormat = NSLocalizedString("Pay %@ and Confirm Parking",
                                                            comment: "Title of the checkout screen payment button")
    static let BlankFieldErrorFormat = NSLocalizedString("Please enter your %@",
                                                         comment: "Error message for a blank field")
    static let SearchSpots = NSLocalizedString("SEARCH SPOTS",
                                               comment: "Button title for search spots button")
    static let LicensePlate = NSLocalizedString("License Plate",
                                                comment: "Title for License Plate row of checkout screen")
    static let LicensePlatePlaceHolder = NSLocalizedString("License Plate (Optional)",
                                                           comment: "Enter License Plate Number")
    static let LicensePlateErrorMessage = NSLocalizedString("Please enter a valid license plate number",
                                                            comment: "Message to indicate that a license plate number is invalid")
    static let CreateReservationErrorMessage = NSLocalizedString("Something went wrong with creating the reservation. Please try again.",
                                                                 comment: "Error message for when a reservation could not be created")
    static let UnknownError = NSLocalizedString( "Unknown Error",
                                                 comment: "Error message when an unknown issue has occured")
    static let Error = NSLocalizedString("Error",
                                         comment: "Title for an Error message")
    static let Okay = NSLocalizedString("OK",
                                        comment: "Title for button to dismiss an error")
    static let Loading = NSLocalizedString("Loading...",
                                           comment: "Loading progress HUD")
    static let BookSpot = NSLocalizedString("Book Spot",
                                            comment: "Book it button title")
    static let NoSpotsAvailable = NSLocalizedString("No spots available",
                                                    comment: "No spots available")
    static let NoSpotsFound = NSLocalizedString("Unfortunately,\nSpotHero does not\nhave parking here yet.",
                                                comment: "Error message for when no spots are found")
    static let Sorry = NSLocalizedString("Sorry",
                                         comment: "Title for no spots error message")
    static let Distance = NSLocalizedString("Distance",
                                            comment: "Distance")
    static let RateExpired = NSLocalizedString("The spot you selected earlier has expired. Please select an updated spot.",
                                               comment: "Error message for when the user comes back to the app")
    static let BookAnother = NSLocalizedString("Book Another",
                                               comment: "Button to book another spot")
    static let CreditCardPlaceHolder = NSLocalizedString("1234 5678 1234 5678",
                                                         comment: "Place holder for credit card field")
    static let ExpirationDatePlaceHolder = NSLocalizedString("MM/YY",
                                                             comment: "Place holder for expiration date field")
    static let CVCPlaceHolder = NSLocalizedString("123",
                                                  comment: "Place holder for cvc field")
    static let ParkSmarter = NSLocalizedString("Park Smarter",
                                               comment: "Title for search view")
    static let SearchDetail = NSLocalizedString("We’ve partnered with SpotHero so you can save up to 50% when you book a great parking spot.",
                                               comment: "Details for search view")
    static let WhereAreYouGoing = NSLocalizedString("Where are you going?",
                                                    comment: "Title for search input")
    static let SearchPlaceholder = NSLocalizedString("Search by address or venue",
                                                     comment: "Place holder for search bar")
    static let AvailableCities = NSLocalizedString("Available Cities",
                                                   comment: "Title for cities table")
    static let RecommendedPlaces = NSLocalizedString("Recommended Places",
                                                     comment: "Title for predictions table")
    static let StartTime = NSLocalizedString("Start Time",
                                             comment: "Start Time Input Placeholder")
    static let EndTime = NSLocalizedString("End Time",
                                           comment: "End Time Input Placeholder")
    static let Next = NSLocalizedString("Next",
                                        comment: "Next button title")
    static let Search = NSLocalizedString("Search",
                                          comment: "Search button title")
    static let WhatTime = NSLocalizedString("What time would\nyou like to park?",
                                            comment: "What time would you like to park label")
    static let ViewDetails = NSLocalizedString("View Details",
                                               comment: "Title for view details buttton")
    static let MoreAmenitiesFormat = NSLocalizedString("+%@ More",
                                                       comment: "Format for more amenities label")
    static let Uncovered = NSLocalizedString("Uncovered",
                                             comment: "Amenity name for uncovered parking")
    static let SpotDetails = NSLocalizedString("Spot Details",
                                               comment: "Title for spot details view")
    static let DistanceFromDestination = NSLocalizedString("Distance From Destination",
                                                           comment: "Title for distance from destination")
    static let HoursOfOperation = NSLocalizedString("Hours of Operation",
                                                   comment: "Title for hours of operation")
    static let Restrictions = NSLocalizedString("Restrictions",
                                                comment: "Title for restrictions")
    static let AboutThisSpot = NSLocalizedString("About This Spot",
                                                 comment: "Title for about this spot")
    static let ReadMore = NSLocalizedString("Read More",
                                            comment: "Title for read more button")
    static let BookSpotFormat = NSLocalizedString("Book Spot | %@",
                                                  comment: "Format for book spot button title")
    static let MoreFormat = NSLocalizedString("+%@ More",
                                              comment: "Fomat for more restrictions button")
    static let ReadLess = NSLocalizedString("Read Less",
                                            comment: "Title for read less button")
    static let WalkingFormat = NSLocalizedString("%@ to %@",
                                                 comment: "Format for walking distance")
    static let Details = NSLocalizedString("Details",
                                           comment: "Details label for checkout")
    static let Checkout = NSLocalizedString("Checkout",
                                            comment: "Title for checkout view")
    static let Confirmation = NSLocalizedString("Confirmation",
                                                comment: "Title for confirmation view")
    static let AllSet = NSLocalizedString("All Set!",
                                          comment: "Title for all set label")
    //swiftlint:disable:next line_length
    static let ConfirmationDetails = NSLocalizedString("Your reservation is confirmed. Check your email for your SpotHero Parking Pass and directions to your spot.",
                                                       comment: "details for confimation view")
    static let Oversized = NSLocalizedString("Oversized fee charged at location.",
                                             comment: "Text for oversized fee callout")
    static let AutoExtension = NSLocalizedString("We’ve extended your times for free!",
                                                 comment: "Text for auto extension callout")
    static let EarlybirdFormat = NSLocalizedString("Enter between %@ - %@ for this price.",
                                                   comment: "Format for text for earlybird callout")
    //swiftlint:disable:next line_length
    static let AutoExtensionFormat = NSLocalizedString("We’ve given you more time at no extra charge! You requested parking:\n\n• %@\n\n\nWe’ve extended your reservation to:\n\n• %@",
                                                       comment: "format for auto extension description")
    static let SameDayFormat = NSLocalizedString("%@ from %@ to %@",
                                                 comment: "Format to time string where dates are on the same day")
    static let DifferentDayFormat = NSLocalizedString("%@ to %@",
                                                      comment: "Format to time string where dates are on the different days")
    static let OversizedTitle = NSLocalizedString("Oversized Fee",
                                                  comment: "Title for oversized fee popover")
    static let AutoExtensionTitle = NSLocalizedString("Extra Time",
                                                      comment: "Title for auto extension popover")
    static let EarlybirdTitle = NSLocalizedString("Online Commuter Rate",
                                                  comment: "Title for text for earlybird popover")
    static let SaveInfo = NSLocalizedString("Save my info for future purchases.",
                                            comment: "Title for save info button")
    static let Remove = NSLocalizedString("remove",
                                          comment: "Title for credit card remove button")
}
