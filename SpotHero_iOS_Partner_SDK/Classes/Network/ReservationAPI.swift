//
//  ReservationAPI.swift
//  Pods
//
//  Created by Matthew Reed on 7/22/16.
//
//

import Foundation

struct ReservationAPI {
    
    /**
     Creates a reservation
     
     - parameter facility:    Facility to create reservation
     - parameter rate:        Rate for the facility
     - parameter email:       User's email address
     - parameter stripeToken: Stripe token for user's credit card
     - parameter license:     User's license plate number. (optional) Pass in nil or omit this parameter if license is not required. If license plate is required and user does not pass it in, pass an empty string
     - parameter completion:  Completion that passes in either a reservation or error
     */
    static func createReservation(facility: Facility,
                                  rate: Rate,
                                  email: String,
                                  stripeToken: String,
                                  license: String? = nil,
                                  completion: (Reservation?, ErrorType?) -> (Void))  {
        
        let starts = DateFormatter.ISO8601NoSeconds.stringFromDate(rate.starts)
        let ends = DateFormatter.ISO8601NoSeconds.stringFromDate(rate.ends)
                
        var params: [String: AnyObject] = [
            "facility_id" : facility.parkingSpotID,
            "rule_group_id" : rate.ruleGroupID,
            "email" : email,
            "starts" : starts,
            "ends" : ends,
            "price" : rate.price,
            "stripe_token" : stripeToken,
        ]
        
        if let license = license where !license.isEmpty {
            params["license_plate"] = license
        } else if license != nil {
            params["license_plate"] = "UNKNOWN"
        }

        let headers = APIHeaders.defaultHeaders()
        
        SpotHeroPartnerAPIController.postJSONtoEndpoint("partner/v1/reservations",
                                                        jsonToPost: params,
                                                        withHeaders: headers,
                                                        errorCompletion: {
                                                            error in
                                                            completion(nil, error)
        }) {
            JSON in
            do {
                guard let data = JSON["data"] as? JSONDictionary else {
                    completion(nil, APIError.parsingError(JSON))
                    return
                }
                
                let reservation  = try Reservation(json: data)
                completion(reservation, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }
    
    /**
     Cancels a reservation
     
     - parameter reservation: Reservation to cancel
     - parameter completion:  Completion block. No parameters
     */
    static func cancelReservation(reservation: Reservation, completion: ((ErrorType?) -> (Void))?) {
        let endpoint = "partner/v1/reservations/\(reservation.rentalID)/cancel"
        let headers = APIHeaders.defaultHeaders()
        let params = [
            "key" : reservation.receiptAccessKey
        ]
        
        SpotHeroPartnerAPIController.postJSONtoEndpoint(endpoint,
                                                        endpointIsDumb: true,
                                                        jsonToPost: params,
                                                        withHeaders: headers,
                                                        errorCompletion: {
                                                            error in
                                                            completion?(error)
        }) {
            JSON in
            completion?(nil)
        }
    }
}
