//
//  StripeWrapper.swift
//  Pods
//
//  Created by Matthew Reed on 7/26/16.
//
//

import Foundation

typealias StripeWrapperCompletion = (String?, ErrorType?) -> (Void)

enum StripeAPIError: ErrorType {
    case CannotGetToken(message: String)
}

struct StripeWrapper {
    static func getToken(number: String,
                         expirationMonth: String,
                         expirationYear: String,
                         cvc: String,
                         completion: StripeWrapperCompletion) {
        
        

        if let url = NSURL(string: "https://api.stripe.com/v1/tokens") {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            request.setValue("Bearer \(ServerEnvironment.CurrentEnvironment.stripeAPIKey)", forHTTPHeaderField: "Authorization")
            
            let body = "card[number]=\(number)&card[exp_month]=\(expirationMonth)&card[exp_year]=\(expirationYear)&card[cvc]=\(cvc)"
            
            request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
            
            NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
                data, response, error in
                guard let data = data else {
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        completion(nil, error)
                    }
                    return
                }
                
                do {
                    let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? JSONDictionary
                    print(jsonDictionary)
                    if let token = jsonDictionary?["id"] as? String {
                        NSOperationQueue.mainQueue().addOperationWithBlock({ 
                            completion(token, nil)
                        })
                    } else if let errorDictionary = jsonDictionary?["error"] as? JSONDictionary, errorMessage = errorDictionary["message"] as? String {
                        NSOperationQueue.mainQueue().addOperationWithBlock({ 
                            completion(nil, StripeAPIError.CannotGetToken(message: errorMessage))
                        })
                    } else {
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            // TODO: Localize
                            completion(nil, StripeAPIError.CannotGetToken(message: "Unknown Error"))
                        })
                    }
                } catch let error {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ 
                        completion(nil, error)
                    })
                }
            }).resume()
        }
    }
}
