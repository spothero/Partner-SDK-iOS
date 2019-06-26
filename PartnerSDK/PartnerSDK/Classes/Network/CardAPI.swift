//
//  CardAPI.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 3/6/18.
//

import Foundation

struct CardAPI {
    typealias Completion = (Error?) -> Void
    
    static func expireToken(for username: String, completion: Completion? = nil) {
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
                                    errorCompletion: { error in
                                        completion?(error)
                                    },
                                    successCompletion: { _ in
                                        completion?(nil)
                                    })
        } catch {
            // Show error
            completion?(error)
        }
     }
}
