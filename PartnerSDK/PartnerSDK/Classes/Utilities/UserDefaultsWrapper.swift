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
        cardType,
        infoSaved,
        lastFour,
        licensePlate,
        phoneNumber,
        username
    }
    
    static var isInfoSaved: Bool {
        return self.boolForKey(.infoSaved)
    }
    
    static var username: String? {
        return self.stringForKey(.username)
    }
    
    static var lastFour: String? {
        return self.stringForKey(.lastFour)
    }
    
    static var cardType: CardType? {
        guard let cardTypeString = self.stringForKey(.cardType) else {
            return .unknown
        }
        
        return CardType(rawValue: cardTypeString)
    }
    
    static var phoneNumber: String? {
        return self.stringForKey(.phoneNumber)
    }
    
    static var licensePlate: String? {
        return self.stringForKey(.licensePlate)
    }
    
    static func setIsInfoSaved(_ isInfoSaved: Bool) {
        self.setBool(isInfoSaved, forKey: .infoSaved)
    }
    
    private static func setValue<T: Any>(_ value: T, forKey key: UserDefaultsKey) {
        UserDefaults.standard.setValue(value, forKey: key.rawValue)
    }
    
    private static func valueForKey<T: Any>(_ key: UserDefaultsKey) -> T? {
        return UserDefaults.standard.value(forKey: key.rawValue) as? T
    }
    
    private static func stringForKey(_ key: UserDefaultsKey) -> String? {
        return UserDefaults.standard.value(forKey: key.rawValue) as? String
    }
    
    private static func setString(_ string: String?, forKey key: UserDefaultsKey) {
        UserDefaults.standard.setValue(string, forKey: key.rawValue)
    }
    
    private static func boolForKey(_ key: UserDefaultsKey) -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }
    
    private static func setBool(_ bool: Bool, forKey key: UserDefaultsKey) {
        UserDefaults.standard.set(bool, forKey: key.rawValue)
    }
    
    static func saveUserInfo(email: String?,
                             phoneNumber: String?,
                             licensePlate: String?,
                             lastFour: String?,
                             cardType: CardType?) {
        UserDefaultsWrapper.setString(email, forKey: .username)
        UserDefaultsWrapper.setString(phoneNumber, forKey: .phoneNumber)
        UserDefaultsWrapper.setString(licensePlate, forKey: .licensePlate)
        UserDefaultsWrapper.setString(lastFour, forKey: .lastFour)
        UserDefaultsWrapper.setString(cardType?.rawValue, forKey: .cardType)
        UserDefaultsWrapper.setIsInfoSaved(true)
    }
    
    static func clearUserInfo() {
        if let userName = self.username {
            CardAPI.expireToken(for: userName)
        }
        UserDefaultsWrapper.setString(nil, forKey: .username)
        UserDefaultsWrapper.setString(nil, forKey: .phoneNumber)
        UserDefaultsWrapper.setString(nil, forKey: .licensePlate)
        UserDefaultsWrapper.setString(nil, forKey: .cardType)
        UserDefaultsWrapper.setString(nil, forKey: .lastFour)
        UserDefaultsWrapper.setIsInfoSaved(false)
    }
}
