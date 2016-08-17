//
//  ReservationAPI.swift
//  Pods
//
//  Created by Matthew Reed on 7/22/16.
//
//

import Foundation

struct ReservationAPI {
    static func createReservation(facility: Facility,
                                  rate: Rate,
                                  email: String,
                                  stripeToken: String,
                                  completion: (Reservation?, ErrorType?) -> (Void))  {
        
        let starts = DateFormatter.ISO8601NoSeconds.stringFromDate(rate.starts)
        let ends = DateFormatter.ISO8601NoSeconds.stringFromDate(rate.ends)
        
        let params: [String: AnyObject] = [
            "facility_id" : facility.parkingSpotID,
            "rule_group_id" : rate.ruleGroupID,
            "email" : email,
            "starts" : starts,
            "ends" : ends,
            "price" : rate.price,
            "stripe_token" : stripeToken
        ]
        
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
