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
    static let LaunchSDK = NSLocalizedString("Launch SDK",
                                             comment: "Launch SDK button title")
    static let FindParking = NSLocalizedString("Find Parking",
                                               comment: "Find parking view title")
    static let BestMatches = NSLocalizedString("BEST MATCHES",
                                               comment: "Places Autocomplete Title")
    static let SetStartTime = NSLocalizedString("Set Start Time",
                                                comment: "Set Start Time")
    static let SetEndTime = NSLocalizedString("Set End Time",
                                                comment: "Set End Time")
    static let Address = NSLocalizedString("Addess",
                                           comment: "Title for address row of checkout screen")
    static let Starts = NSLocalizedString("Starts",
                                          comment: "Title for start date row of checkout screen")
    static let Ends = NSLocalizedString("Ends",
                                        comment: "Title for end date row of checkout screen")
    static let FullName = NSLocalizedString("Full Name",
                                        comment: "Title for Full Name row of checkout screen")
    static let Email = NSLocalizedString("Email",
                                           comment: "Title for Email row of checkout screen")
    static let Phone = NSLocalizedString("Phone",
                                         comment: "Title for Phone number row of checkout screen")
    static let EnterFullName = NSLocalizedString("Enter Full Name",
                                                 comment: "Placeholder for Full Name row of checkout screen")
    static let EnterEmailAddress = NSLocalizedString("Enter Email Address",
                                                 comment: "Placeholder for Email row of checkout screen")
    static let EnterPhoneNumber = NSLocalizedString("Enter Phone Number",
                                                 comment: "Placeholder for Phone Number row of checkout screen")
    static let ReservationInfo = NSLocalizedString("RESERVATION INFO",
                                                   comment: "Title for reservation info section of checkout screen")
    static let PersonalInfo = NSLocalizedString("PERSONAL INFO",
                                                comment: "Title for personal info section of checkout screen")
    static let PaymentInfo = NSLocalizedString("PAYMENT INFO",
                                               comment: "Title for payment info section of checkout screen")
    static let CreditCardWarning = NSLocalizedString("A credit card is required to guarantee your reservation. It will not be charged until the reservation starts.",
                                                     comment: "Label explaining that a credit card is required to guarantee a reservation")
    static let CreditCard = NSLocalizedString("Credit Card",
                                              comment: "Name of credit card field")
    static let ExpirationDate = NSLocalizedString("Expiration Date",
                                                  comment: "Name of expiration date field")
    static let CVC = NSLocalizedString("CVC",
                                       comment: "Name of CVC field")
    static let ZipCode = NSLocalizedString("Zip Code",
                                       comment: "Name of zip code field")
    static let FullNameErrorMessage = NSLocalizedString("Please enter a valid full name",
                                    comment: "Error message for an invalid full name")
    static let EmailErrorMessage = NSLocalizedString("Please enter a valid email",
                                    comment: "Error message for an invalid email")
    static let PhoneErrorMessage = NSLocalizedString("Please enter a valid phone number",
                                                     comment: "Error message for an invalid phone number")
    static let CreditCardErrorMessage = NSLocalizedString("Please enter a valid credit card",
                                                comment: "Error message for an invalid credit card")
    static let NonAcceptedCreditCardErrorMessage = NSLocalizedString("Please enter a Visa, Discover, MasterCard, or American Express card",
                                                comment: "Error message for a credit card that is not a Visa, Discover, MasterCard, or American Express card")
    static let InvalidDateErrorMessage = NSLocalizedString("Please enter a valid expiration date",
                                                comment: "Error message for an invalid expiration date")
    static let DateInThePastErrorMessage = NSLocalizedString("Please enter an expiration date in the future",
                                                comment: "Error message for an expiration date in the past")
    static let CVCErrorMessage = NSLocalizedString("Please enter a valid cvc",
                                                comment: "Error message for an invalid cvc")
    static let ZipErrorMessage = NSLocalizedString("Please enter a valid zip code",
                                                comment: "Error message for an invalid zip code")
    static let Visa = NSLocalizedString("Visa",
                                        comment: "A Visa Credit Card")
    static let Amex = NSLocalizedString("American Express",
                                        comment: "An American Express Credit Card")
    static let MasterCard = NSLocalizedString("MasterCard",
                                        comment: "A MasterCard Credit Card")
    static let Discover = NSLocalizedString("Visa",
                                        comment: "A Discover Credit Card")
    static let paymentButtonTitleFormat = NSLocalizedString("Pay %@ and Confirm Parking",
                                                      comment: "Title of the checkout screen payment button")
    static let blankFieldErrorFormat = NSLocalizedString("Please enter your %@",
                                                   comment: "Error message for a blank field")
}
