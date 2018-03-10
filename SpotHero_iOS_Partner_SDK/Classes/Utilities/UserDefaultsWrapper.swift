//
//  UserDefaultsWrapper.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by Matthew Reed on 3/5/18.
//

import Foundation

struct UserDefaultsWrapper {
    enum UserDefaultsKey: String {
        case
        username,
        lastFour,
        cardType,
        infoSaved
    }
    
    static var isInfoSaved: Bool {
        return UserDefaultsWrapper.boolForKey(.infoSaved)
    }
    
    static var username: String? {
        return UserDefaultsWrapper.stringForKey(.username)
    }
    
    static var lastFour: String? {
        return UserDefaultsWrapper.stringForKey(.lastFour)
    }
    
    static var cardType: CardType? {
        guard let cardTypeString = UserDefaultsWrapper.stringForKey(.cardType) else {
            return .unknown
        }
        
        return CardType(rawValue: cardTypeString)
    }
    
    private static func setValue<T: Any>(_ value: T, forKey key: UserDefaultsKey) {
        UserDefaults.standard.setValue(value, forKey: key.rawValue)
    }
    
    private static func valueForKey<T: Any>(_ key: UserDefaultsKey) -> T? {
        return UserDefaults.standard.value(forKey: key.rawValue) as? T
    }
    
    private static func stringForKey(_ key: UserDefaultsKey) -> String? {
        return UserDefaults.standard
            .value(forKey: key.rawValue) as? String
    }
    
    private static func setString(_ string: String?, forKey key: UserDefaultsKey) {
        UserDefaults.standard
            .setValue(string, forKey: key.rawValue)
    }
    
    private static func boolForKey(_ key: UserDefaultsKey) -> Bool {
        return UserDefaults.standard
            .bool(forKey: key.rawValue)
    }
    
    private static func setBool(_ bool: Bool, forKey key: UserDefaultsKey) {
        UserDefaults.standard
            .set(bool, forKey: key.rawValue)
    }
    
    static func saveUserInfo(email: String?,
                             lastFour: String?,
                             cardType: CardType?) {
        UserDefaultsWrapper.setString(email, forKey: .username)
        UserDefaultsWrapper.setString(lastFour, forKey: .lastFour)
        UserDefaultsWrapper.setString(cardType?.rawValue, forKey: .cardType)
        UserDefaultsWrapper.setBool(true, forKey: .infoSaved)
    }
    
    /// Clear users info
    ///
    /// - Parameter completion: pass in the completion block if you need to expire the user's token
    static func clearUserInfo(completion: CardAPI.Completion? = nil) {
        UserDefaultsWrapper.setString(nil, forKey: .cardType)
        UserDefaultsWrapper.setString(nil, forKey: .lastFour)
        UserDefaultsWrapper.setBool(false, forKey: .infoSaved)
        if let completion = completion {
            CardAPI.expireToken(completion: completion)
        }
    }
}
