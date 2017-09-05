//
//  DateFormatter.swift
//  Pods
//
//  Created by Matthew Reed on 7/22/16.
//
//

import Foundation

class SHPDateFormatter: NSObject {
    
    private enum ISO8601Format: String, StringEnum {
        case
        NoTime = "yyyy-MM-dd",
        NoMillisecondsUTC = "yyyy-MM-dd'T'HH:mm:ssZ",
        NoMilliseconds = "yyyy-MM-dd'T'HH:mm:ss",
        NoSeconds = "yyyy-MM-dd'T'HH:mm"
    }
    
    private enum APIFormat: String, StringEnum {
        case
        NoTime = "MM-dd-yyyy",
        APITime = "HH:mm:ss",
        TimeOnly = "hmma"
    }
    
    private enum DateFormat: String, StringEnum {
        case
        NoTime = "MM/dd/yyyy",
        DateOnlyNoYear = "MM/dd",
        TimeOnly = "h:mma",
        PrettyDayDateTime = "EEE MMM d 'at' h:mma",
        MMDDHmma = "MM/dd h:mm a",
        PrettyDayDate = "EEE, MMM d",
        LinkDateTime = "MM-dd-yyyy hhmma",
        PrettyMonthDayDate = "MMM dd, yyyy",
        DayOfWeekWithDate = "EEEE, MM/dd"
    }
    
    private static func formatterWithFormat(_ format: StringEnum) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        if
            format.rawValue == APIFormat.TimeOnly.rawValue
            || format.rawValue == ISO8601Format.NoMillisecondsUTC.rawValue {
                formatter.locale = Locale(identifier: "en_US")
        }
        
        return formatter
    }
    
    private static func relativeFormatterWithFormat() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
        return formatter
    }
    
    class func formatter(_ dateFormatter: DateFormatter, inTimeZoneName timeZoneName: String?) -> DateFormatter {
        if let timeZoneName = timeZoneName {
            dateFormatter.timeZone = TimeZone(identifier: timeZoneName)
        } else {
            dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        }
        return dateFormatter
    }
    
    //MARK: ISO8601Format
    
    ///A formatter for translating ISO8601 dates without time
    static let ISO8601NoTime: DateFormatter = SHPDateFormatter.formatterWithFormat(ISO8601Format.NoTime)
    
    ///A formatter for translating ISO8601 dates in UTC with seconds but without milliseconds.
    static let ISO8601NoMillisecondsUTC: DateFormatter = SHPDateFormatter.formatterWithFormat(ISO8601Format.NoMillisecondsUTC)
    
    ///A formatter for translating ISO8601 dates with seconds but without milliseconds
    static let ISO8601NoMilliseconds: DateFormatter = SHPDateFormatter.formatterWithFormat(ISO8601Format.NoMilliseconds)
    
    ///A formatter for translating ISO8601 dates without seconds
    static let ISO8601NoSeconds: DateFormatter = SHPDateFormatter.formatterWithFormat(ISO8601Format.NoSeconds)
    
    //MARK: APIFormat
    
    ///A formatter for translating API dates without time
    static let APINoTime: DateFormatter = SHPDateFormatter.formatterWithFormat(APIFormat.NoTime)
    
    //A formatter for translating API times
    static let APITime: DateFormatter = SHPDateFormatter.formatterWithFormat(APIFormat.APITime)
    
    ///A formatter for translating API times
    static let APITimeOnly: DateFormatter = SHPDateFormatter.formatterWithFormat(APIFormat.TimeOnly)
    
    //MARK: DateFormat
    
    ///A formatter for translating dates without time
    static let NoTime: DateFormatter = SHPDateFormatter.formatterWithFormat(DateFormat.NoTime)
    
    ///A formatter for translating dates without year and without time
    static let DateOnlyNoYear: DateFormatter = SHPDateFormatter.formatterWithFormat(DateFormat.DateOnlyNoYear)
    
    ///A formatter for translating time only dates
    static let TimeOnly: DateFormatter = SHPDateFormatter.formatterWithFormat(DateFormat.TimeOnly)
    
    ///A formatter for translating pretty day date times
    static let PrettyDayDateTime: DateFormatter = SHPDateFormatter.formatterWithFormat(DateFormat.PrettyDayDateTime)
    
    ///A formatter for translating mmddhmma dates
    static let MMDDHmma: DateFormatter = SHPDateFormatter.formatterWithFormat(DateFormat.MMDDHmma)
    
    ///A formatter for translating pretty day dates
    static let PrettyDayDate: DateFormatter = SHPDateFormatter.formatterWithFormat(DateFormat.PrettyDayDate)
    
    ///A formatter for translating link date times
    static let LinkDateTime: DateFormatter = SHPDateFormatter.formatterWithFormat(DateFormat.LinkDateTime)
    
    //A formatter for translating pretty month day dates
    static let PrettyMonthDayDate: DateFormatter = SHPDateFormatter.formatterWithFormat(DateFormat.PrettyMonthDayDate)
    
    //A formatter for getting the day of the week
    static let DayOfWeekWithDate: DateFormatter = SHPDateFormatter.formatterWithFormat(DateFormat.DayOfWeekWithDate)

    ///A formatter for translating relative dates
    static let RelativeDate: DateFormatter = SHPDateFormatter.relativeFormatterWithFormat()
    
}
