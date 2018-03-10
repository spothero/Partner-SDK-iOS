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
        noTime = "yyyy-MM-dd",
        noMillisecondsUTC = "yyyy-MM-dd'T'HH:mm:ssZ",
        noMilliseconds = "yyyy-MM-dd'T'HH:mm:ss",
        noSeconds = "yyyy-MM-dd'T'HH:mm"
    }
    
    private enum APIFormat: String, StringEnum {
        case
        noTime = "MM-dd-yyyy",
        apiTime = "HH:mm:ss",
        timeOnly = "hmma",
        onlineCommuter = "h:mm a"
    }
    
    private enum DateFormat: String, StringEnum {
        case
        noTime = "MM/dd/yyyy",
        dateOnlyNoYear = "MMM d",
        timeOnly = "h:mma",
        timeOnlyNoMins = "ha",
        prettyDayDateTime = "EEE MMM d 'at' h:mma",
        dateWithTime = "M/dd h:mma",
        dateWithTimeNoComma = "MMM dd h:mma",
        dateWithTimeNoSlash = "MMM dd, h:mma",
        prettyDayDate = "EEE, MMM d",
        linkDateTime = "MM-dd-yyyy hhmma",
        prettyMonthDayDate = "MMM dd, yyyy",
        dayOfWeekWithDate = "EEEE, MM/dd"
    }
    
    private static func formatterWithFormat(_ format: StringEnum) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        if
            format.rawValue == APIFormat.timeOnly.rawValue
            || format.rawValue == ISO8601Format.noMillisecondsUTC.rawValue {
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
    static let ISO8601NoTime: DateFormatter = SHPDateFormatter.formatterWithFormat(ISO8601Format.noTime)
    
    ///A formatter for translating ISO8601 dates in UTC with seconds but without milliseconds.
    static let ISO8601NoMillisecondsUTC: DateFormatter = SHPDateFormatter.formatterWithFormat(ISO8601Format.noMillisecondsUTC)
    
    ///A formatter for translating ISO8601 dates with seconds but without milliseconds
    static let ISO8601NoMilliseconds: DateFormatter = SHPDateFormatter.formatterWithFormat(ISO8601Format.noMilliseconds)
    
    ///A formatter for translating ISO8601 dates without seconds
    static let ISO8601NoSeconds: DateFormatter = SHPDateFormatter.formatterWithFormat(ISO8601Format.noSeconds)
    
    //MARK: APIFormat
    
    ///A formatter for translating API dates without time
    static let APINoTime: DateFormatter = SHPDateFormatter.formatterWithFormat(APIFormat.noTime)
    
    //A formatter for translating API times
    static let APITime: DateFormatter = SHPDateFormatter.formatterWithFormat(APIFormat.apiTime)
    
    ///A formatter for translating API times
    static let APITimeOnly: DateFormatter = SHPDateFormatter.formatterWithFormat(APIFormat.timeOnly)
    
    ///A formatter for online commuter rate times
    static let APIOnlineCommuter: DateFormatter = SHPDateFormatter.formatterWithFormat(APIFormat.onlineCommuter)
    
    //MARK: DateFormat
    
    ///A formatter for translating dates without time
    static let NoTime: DateFormatter = SHPDateFormatter.formatterWithFormat(DateFormat.noTime)
    
    ///A formatter for translating dates without year and without time
    static let DateOnlyNoYear: DateFormatter = SHPDateFormatter.formatterWithFormat(DateFormat.dateOnlyNoYear)
    
    ///A formatter for translating time only dates
    static let TimeOnly: DateFormatter = SHPDateFormatter.formatterWithFormat(DateFormat.timeOnly)
    
    ///A formatter for translating time only dates with no minutes
    static let TimeOnlyNoMins: DateFormatter = SHPDateFormatter.formatterWithFormat(DateFormat.timeOnlyNoMins)
    
    ///A formatter for translating pretty day date times
    static let PrettyDayDateTime: DateFormatter = SHPDateFormatter.formatterWithFormat(DateFormat.prettyDayDateTime)
    
    ///A formatter for translating dates with time
    static let DateWithTime: DateFormatter = SHPDateFormatter.formatterWithFormat(DateFormat.dateWithTime)
    
    ///A formatter for translating dates with time without a comma
    static let DateWithTimeNoComma: DateFormatter = SHPDateFormatter.formatterWithFormat(DateFormat.dateWithTimeNoComma)
    
    ///A formatter for translating dates with time without a slash
    static let DateWithTimeNoSlash: DateFormatter = SHPDateFormatter.formatterWithFormat(DateFormat.dateWithTimeNoSlash)
    
    ///A formatter for translating pretty day dates
    static let PrettyDayDate: DateFormatter = SHPDateFormatter.formatterWithFormat(DateFormat.prettyDayDate)
    
    ///A formatter for translating link date times
    static let LinkDateTime: DateFormatter = SHPDateFormatter.formatterWithFormat(DateFormat.linkDateTime)
    
    //A formatter for translating pretty month day dates
    static let PrettyMonthDayDate: DateFormatter = SHPDateFormatter.formatterWithFormat(DateFormat.prettyMonthDayDate)
    
    //A formatter for getting the day of the week
    static let DayOfWeekWithDate: DateFormatter = SHPDateFormatter.formatterWithFormat(DateFormat.dayOfWeekWithDate)

    ///A formatter for translating relative dates
    static let RelativeDate: DateFormatter = SHPDateFormatter.relativeFormatterWithFormat()
    
}
