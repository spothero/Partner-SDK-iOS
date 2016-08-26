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
     - parameter license:     User's license plate number. (optional) 
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
        
        if let license = license {
            params["license_plate"] = license
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
                let reservation  = try Reservation(json: JSON)
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
