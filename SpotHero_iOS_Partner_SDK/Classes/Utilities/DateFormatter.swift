//
//  DateFormatter.swift
//  Pods
//
//  Created by Matthew Reed on 7/22/16.
//
//

import Foundation

class DateFormatter: NSObject {
    
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
    
    private static func formatterWithFormat(format: StringEnum) -> NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.AMSymbol = "am"
        formatter.PMSymbol = "pm"
        if (format.rawValue == APIFormat.TimeOnly.rawValue || format.rawValue == ISO8601Format.NoMillisecondsUTC.rawValue) {
            formatter.locale = NSLocale(localeIdentifier: "en_US")
        }
        
        return formatter
    }
    
    private static func relativeFormatterWithFormat() -> NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        formatter.doesRelativeDateFormatting = true
        return formatter
    }
    
    class func formatter(dateFormatter: NSDateFormatter, inTimeZoneName timeZoneName: String?) -> NSDateFormatter {
        if let timeZoneName = timeZoneName {
            dateFormatter.timeZone = NSTimeZone(name: timeZoneName)
        } else {
            dateFormatter.timeZone = NSTimeZone.localTimeZone()
        }
        return dateFormatter
    }
    
    //MARK: ISO8601Format
    
    ///A formatter for translating ISO8601 dates without time
    static let ISO8601NoTime: NSDateFormatter = DateFormatter.formatterWithFormat(ISO8601Format.NoTime)
    
    ///A formatter for translating ISO8601 dates in UTC with seconds but without milliseconds.
    static let ISO8601NoMillisecondsUTC: NSDateFormatter = DateFormatter.formatterWithFormat(ISO8601Format.NoMillisecondsUTC)
    
    ///A formatter for translating ISO8601 dates with seconds but without milliseconds
    static let ISO8601NoMilliseconds: NSDateFormatter = DateFormatter.formatterWithFormat(ISO8601Format.NoMilliseconds)
    
    ///A formatter for translating ISO8601 dates without seconds
    static let ISO8601NoSeconds: NSDateFormatter = DateFormatter.formatterWithFormat(ISO8601Format.NoSeconds)
    
    //MARK: APIFormat
    
    ///A formatter for translating API dates without time
    static let APINoTime: NSDateFormatter = DateFormatter.formatterWithFormat(APIFormat.NoTime)
    
    //A formatter for translating API times
    static let APITime: NSDateFormatter = DateFormatter.formatterWithFormat(APIFormat.APITime)
    
    ///A formatter for translating API times
    static let APITimeOnly: NSDateFormatter = DateFormatter.formatterWithFormat(APIFormat.TimeOnly)
    
    //MARK: DateFormat
    
    ///A formatter for translating dates without time
    static let NoTime: NSDateFormatter = DateFormatter.formatterWithFormat(DateFormat.NoTime)
    
    ///A formatter for translating dates without year and without time
    static let DateOnlyNoYear: NSDateFormatter = DateFormatter.formatterWithFormat(DateFormat.DateOnlyNoYear)
    
    ///A formatter for translating time only dates
    static let TimeOnly: NSDateFormatter = DateFormatter.formatterWithFormat(DateFormat.TimeOnly)
    
    ///A formatter for translating pretty day date times
    static let PrettyDayDateTime: NSDateFormatter = DateFormatter.formatterWithFormat(DateFormat.PrettyDayDateTime)
    
    ///A formatter for translating mmddhmma dates
    static let MMDDHmma: NSDateFormatter = DateFormatter.formatterWithFormat(DateFormat.MMDDHmma)
    
    ///A formatter for translating pretty day dates
    static let PrettyDayDate: NSDateFormatter = DateFormatter.formatterWithFormat(DateFormat.PrettyDayDate)
    
    ///A formatter for translating link date times
    static let LinkDateTime: NSDateFormatter = DateFormatter.formatterWithFormat(DateFormat.LinkDateTime)
    
    //A formatter for translating pretty month day dates
    static let PrettyMonthDayDate: NSDateFormatter = DateFormatter.formatterWithFormat(DateFormat.PrettyMonthDayDate)
    
    //A formatter for getting the day of the week
    static let DayOfWeekWithDate: NSDateFormatter = DateFormatter.formatterWithFormat(DateFormat.DayOfWeekWithDate)

    ///A formatter for translating relative dates
    static let RelativeDate: NSDateFormatter = DateFormatter.relativeFormatterWithFormat()
    
}
