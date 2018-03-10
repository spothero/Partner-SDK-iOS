//
//  CardAPI.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 3/6/18.
//

import Foundation

struct CardAPI {
    typealias Completion = (Error?) -> Void
    
    static func expireToken(completion: Completion? = nil) {
        guard let username = UserDefaultsWrapper.username else {
            assertionFailure("This shouldn't be called with out saved user info")
            return
        }
                
        let keychainItem = KeychainPasswordItem(account: username)
        do {
            let token = try keychainItem.readPassword()
            try keychainItem.deleteItem()
            let endpoint = "partner/v1/cards/\(token)/expire"
            let headers = APIHeaders.defaultHeaders()
            SpotHeroPartnerAPIController
                .postJSONtoEndpoint(endpoint,
                                    jsonToPost: [:],
                                    withHeaders: headers,
                                    errorCompletion: {
                                        error in
                                        completion?(error)
                                    },
                                    successCompletion: {
                                        _ in
                                        completion?(nil)
                                    })
        } catch let error {
            // Show error
            completion?(error)
        }
     }
}
