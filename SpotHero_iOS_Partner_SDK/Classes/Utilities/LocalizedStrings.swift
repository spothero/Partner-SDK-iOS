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
}
