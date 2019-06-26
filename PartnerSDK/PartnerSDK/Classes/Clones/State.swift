//
//  State.swift
//  SpotHero
//
//  Created by SpotHeroJoe on 5/29/18.
//  Copyright © 2018 SpotHero, Inc. All rights reserved.
//

import Foundation

struct State: Codable {
    let name: String
    let abbreviation: String
    
    static let allStates = [
        State(name: "Alabama", abbreviation: "AL"),
        State(name: "Alaska", abbreviation: "AK"),
        State(name: "Alberta", abbreviation: "AB"),
        State(name: "American Samoa", abbreviation: "AS"),
        State(name: "Arizona", abbreviation: "AZ"),
        State(name: "Arkansas", abbreviation: "AR"),
        State(name: "British Columbia", abbreviation: "BC"),
        State(name: "California", abbreviation: "CA"),
        State(name: "Colorado", abbreviation: "CO"),
        State(name: "Connecticut", abbreviation: "CT"),
        State(name: "Delaware", abbreviation: "DE"),
        State(name: "District of Columbia", abbreviation: "DC"),
        State(name: "Florida", abbreviation: "FL"),
        State(name: "Georgia", abbreviation: "GA"),
        State(name: "Guam", abbreviation: "GU"),
        State(name: "Hawaii", abbreviation: "HI"),
        State(name: "Idaho", abbreviation: "ID"),
        State(name: "Illinois", abbreviation: "IL"),
        State(name: "Indiana", abbreviation: "IN"),
        State(name: "Iowa", abbreviation: "IA"),
        State(name: "Kansas", abbreviation: "KS"),
        State(name: "Kentucky", abbreviation: "KY"),
        State(name: "Louisiana", abbreviation: "LA"),
        State(name: "Maine", abbreviation: "ME"),
        State(name: "Manitoba", abbreviation: "MB"),
        State(name: "Maryland", abbreviation: "MD"),
        State(name: "Massachusetts", abbreviation: "MA"),
        State(name: "Michigan", abbreviation: "MI"),
        State(name: "Minnesota", abbreviation: "MN"),
        State(name: "Mississippi", abbreviation: "MS"),
        State(name: "Missouri", abbreviation: "MO"),
        State(name: "Montana", abbreviation: "MT"),
        State(name: "Nebraska", abbreviation: "NE"),
        State(name: "Nevada", abbreviation: "NV"),
        State(name: "New Brunswick", abbreviation: "NB"),
        State(name: "New Hampshire", abbreviation: "NH"),
        State(name: "New Jersey", abbreviation: "NJ"),
        State(name: "New Mexico", abbreviation: "NM"),
        State(name: "New York", abbreviation: "NY"),
        State(name: "Newfoundland and Labrador", abbreviation: "NL"),
        State(name: "North Carolina", abbreviation: "NC"),
        State(name: "North Dakota", abbreviation: "ND"),
        State(name: "Northern Mariana Islands", abbreviation: "MP"),
        State(name: "Northwest Territories", abbreviation: "NT"),
        State(name: "Nova Scotia", abbreviation: "NS"),
        State(name: "Nunavut", abbreviation: "NU"),
        State(name: "Ohio", abbreviation: "OH"),
        State(name: "Oklahoma", abbreviation: "OK"),
        State(name: "Ontario", abbreviation: "ON"),
        State(name: "Oregon", abbreviation: "OR"),
        State(name: "Pennsylvania", abbreviation: "PA"),
        State(name: "Prince Edward Island", abbreviation: "PE"),
        State(name: "Puerto Rico", abbreviation: "PR"),
        State(name: "Quebec", abbreviation: "QC"),
        State(name: "Rhode Island", abbreviation: "RI"),
        State(name: "Saskatchewan", abbreviation: "SK"),
        State(name: "South Carolina", abbreviation: "SC"),
        State(name: "South Dakota", abbreviation: "SD"),
        State(name: "Tennessee", abbreviation: "TN"),
        State(name: "Texas", abbreviation: "TX"),
        State(name: "United States Virgin Islands", abbreviation: "VI"),
        State(name: "Utah", abbreviation: "UT"),
        State(name: "Vermont", abbreviation: "VT"),
        State(name: "Virginia", abbreviation: "VA"),
        State(name: "Washington", abbreviation: "WA"),
        State(name: "West Virginia", abbreviation: "WV"),
        State(name: "Wisconsin", abbreviation: "WI"),
        State(name: "Wyoming", abbreviation: "WY"),
        State(name: "Yukon Territory", abbreviation: "YT"),
    ]
}
