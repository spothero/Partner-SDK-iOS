//
//  ReservationAPI.swift
//  Pods
//
//  Created by Matthew Reed on 7/22/16.
//
//

import Foundation

struct ReservationAPI {
    private static var LastReservation: Reservation?
    
    /**
     Creates a reservation
     
     - parameter facility:    Facility to create reservation
     - parameter rate:        Rate for the facility
     - parameter email:       User's email address
     - parameter stripeToken: Stripe token for user's credit card
     - parameter license:     User's license plate number. (optional)
                              Pass in nil or omit this parameter if license is not required. 
                              If license plate is required and user does not pass it in, pass an empty string
     - parameter completion:  Completion that passes in either a reservation or error
     */
    static func createReservation(_ facility: Facility,
                                  rate: Rate,
                                  email: String,
                                  phone: String? = nil,
                                  stripeToken: String? = nil,
                                  partnerRenterCardToken: String? = nil,
                                  license: String? = nil,
                                  saveInfo: Bool,
                                  completion: @escaping (Reservation?, Error?) -> Void) {
        let formatter = SHPDateFormatter.ISO8601NoSeconds
        let previousTimeZone = formatter.timeZone
        formatter.timeZone = TimeZone(identifier: facility.timeZone)
        let starts = formatter.string(from: rate.starts)
        let ends = formatter.string(from: rate.ends)
        formatter.timeZone = previousTimeZone
        
        var params: [String: Any] = [
            "facility_id" : facility.parkingSpotID,
            "rule_group_id" : rate.ruleGroupID,
            "email" : email,
            "starts" : starts,
            "ends" : ends,
            "price" : rate.price,
            ]
        
        if let stripeToken = stripeToken {
            params["stripe_token"] = stripeToken
            params["save_partner_renter_card"] = saveInfo
        } else if let partnerRenterCardToken = partnerRenterCardToken {
            params["partner_renter_card_token"] = partnerRenterCardToken
        } else {
            assertionFailure("You should either have a renter token or stripe token")
        }
        
        if let license = license,
            !license.isEmpty {
                params["license_plate"] = license
        } else if license != nil {
            params["license_plate"] = "UNKNOWN"
        }

        if let phone = phone,
            !phone.isEmpty {
                params["phone_number"] = phone
        }
        
        let headers = APIHeaders.defaultHeaders()
        
        SpotHeroPartnerAPIController.postJSONtoEndpoint("partner/v1/reservations",
                                                        endpointIsDumb: true,
                                                        jsonToPost: params,
                                                        withHeaders: headers,
                                                        errorCompletion: {
                                                            error in
                                                            completion(nil, error)
                                                        },
                                                        successCompletion: {
                                                            JSON in
                                                            do {
                                                                guard let data = JSON["data"] as? JSONDictionary else {
                                                                    completion(nil, APIError.parsingError(JSON))
                                                                    return
                                                                }
                
                                                                let reservation = try Reservation(json: data)
                                                                self.LastReservation = reservation
                                                                completion(reservation, nil)
                                                            } catch let error {
                                                                completion(nil, error)
                                                            }
                                                       })
    }
    
    /**
     Cancels a reservation
     
     - parameter reservation: Reservation to cancel
     - parameter completion:  Completion block. No parameters
     */
    static func cancelReservation(_ reservation: Reservation, completion: ((Error?) -> Void)?) {
        let endpoint = "partner/v1/reservations/\(reservation.rentalID)/cancel"
        let headers = APIHeaders.defaultHeaders()
        let params = [
            "key" : reservation.receiptAccessKey,
        ]
        
        SpotHeroPartnerAPIController.postJSONtoEndpoint(endpoint,
                                                        endpointIsDumb: true,
                                                        jsonToPost: params,
                                                        withHeaders: headers,
                                                        errorCompletion: {
                                                            error in
                                                            completion?(error)
                                                        },
                                                        successCompletion: {
                                                            _ in
                                                            completion?(nil)
                                                        })
    }
    
    static func cancelLastReservation(completion: @escaping ((Bool) -> Void)) {
        guard let reservation = self.LastReservation else {
            completion(false)
            return
        }
        
        self.cancelReservation(reservation) {
            error in
            completion(error == nil)
        }
    }
}
