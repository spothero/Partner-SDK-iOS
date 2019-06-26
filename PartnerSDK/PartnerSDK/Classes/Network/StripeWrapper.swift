//
//  StripeWrapper.swift
//  Pods
//
//  Created by Matthew Reed on 7/26/16.
//
//

import Foundation

typealias StripeWrapperCompletion = (String?, Error?) -> Void

enum StripeAPIError: Error {
    case cannotGetToken(message: String)
}

struct StripeWrapper {
    static func getToken(_ number: String,
                         expirationMonth: String,
                         expirationYear: String,
                         cvc: String,
                         completion: @escaping StripeWrapperCompletion) {
        
        if let url = URL(string: "https://api.stripe.com/v1/tokens") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            request.setValue("Bearer \(ServerEnvironment.CurrentEnvironment.stripeAPIKey)", forHTTPHeaderField: "Authorization")
            
            let body = "card[number]=\(number)&card[exp_month]=\(expirationMonth)&card[exp_year]=\(expirationYear)&card[cvc]=\(cvc)"
            
            request.httpBody = body.data(using: .utf8)
            
            let dataTask = SharedURLSession.sharedInstance.session.dataTask(with: request) { data, _, error in
                OperationQueue.main.addOperation {
                    guard let data = data else {
                        completion(nil, error)
                        return
                    }
                    
                    do {
                        let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
                        if let token = jsonDictionary?["id"] as? String {
                            completion(token, nil)
                        } else if
                            let errorDictionary = jsonDictionary?["error"] as? JSONDictionary,
                            let errorMessage = errorDictionary["message"] as? String {
                                completion(nil, StripeAPIError.cannotGetToken(message: errorMessage))
                        } else {
                            completion(nil, StripeAPIError.cannotGetToken(message: LocalizedStrings.UnknownError))
                        }
                    } catch {
                        completion(nil, error)
                    }
                }
            }
            dataTask.resume()
        }
    }
}
