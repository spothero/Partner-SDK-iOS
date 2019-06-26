//
//  NSDateTests.swift
//  SpotHero_iOS_Partner_SDK
//
//  Created by SpotHeroMatt on 9/28/16.
//  Copyright © 2016 SpotHero, Inc. All rights reserved.
//

@testable import SpotHero_iOS_Partner_SDK
import XCTest

class NSDateTests: XCTestCase {
    
    // Helpers
    
    func checkTime(_ date: Date,
                   roundUpMinute: Int,
                   roundDownMinute: Int,
                   hour: Int,
                   file: StaticString = #file,
                   line: UInt = #line) {
        let roundedUp = date.shp_roundDateToNearestHalfHour(roundDown: false)
        let roundedDown = date.shp_roundDateToNearestHalfHour(roundDown: true)
        
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        guard let timeZone = TimeZone(identifier: "America/Chicago") else {
                XCTFail("Cannot creat calendar or timezone")
                return
        }
        
        calendar.timeZone = timeZone
        
        let roundedUpComponents = calendar.dateComponents([.minute, .hour], from: roundedUp)
        let roundedDownComponents = calendar.dateComponents([.minute], from: roundedDown)
        
        XCTAssertEqual(roundedUpComponents.minute,
                       roundUpMinute,
                       file: file,
                       line: line)
        XCTAssertEqual(roundedDownComponents.minute,
                       roundDownMinute,
                       file: file,
                       line: line)
        XCTAssertEqual(roundedUpComponents.hour,
                       hour,
                       file: file,
                       line: line)
    }
    
    // TODO: test for Daylight savings time, seconds and new years eve
    
    func testRoundingMinutes() {
        // 8:00pm CST
        let nonRounding = Date(timeIntervalSince1970: 1_475_110_800)
        
        self.checkTime(nonRounding,
                       roundUpMinute: 30,
                       roundDownMinute: 0,
                       hour: 20)
        
        // 8:01pm CST
        let onePast = Date(timeIntervalSince1970: 1_475_110_860)
        
        self.checkTime(onePast,
                       roundUpMinute: 30,
                       roundDownMinute: 0,
                       hour: 20)
        
        // 8:15pm CST
        let fifteenPast = Date(timeIntervalSince1970: 1_475_111_700)
        
        self.checkTime(fifteenPast,
                       roundUpMinute: 30,
                       roundDownMinute: 0,
                       hour: 20)
        
        // 8:29pm CST
        let oneMinuteBeforeThirty = Date(timeIntervalSince1970: 1_475_112_540)
        
        self.checkTime(oneMinuteBeforeThirty,
                       roundUpMinute: 30,
                       roundDownMinute: 0,
                       hour: 20)
        
        // 8:30pm CST
        let nonRoundingThirty = Date(timeIntervalSince1970: 1_475_112_600)
        
        self.checkTime(nonRoundingThirty,
                       roundUpMinute: 0,
                       roundDownMinute: 30,
                       hour: 21)
       
        // 8:31pm CST
        let onePastThirty = Date(timeIntervalSince1970: 1_475_112_660)
        
        self.checkTime(onePastThirty,
                       roundUpMinute: 0,
                       roundDownMinute: 30,
                       hour: 21)
        
        // 8:45pm CST
        let fifteenPastThirty = Date(timeIntervalSince1970: 1_475_113_500)

        self.checkTime(fifteenPastThirty,
                       roundUpMinute: 0,
                       roundDownMinute: 30,
                       hour: 21)
        
        // 8:59pm CST
        let oneMinuteBefore = Date(timeIntervalSince1970: 1_475_114_340)
        
        self.checkTime(oneMinuteBefore,
                       roundUpMinute: 0,
                       roundDownMinute: 30,
                       hour: 21)
    }
    
}
