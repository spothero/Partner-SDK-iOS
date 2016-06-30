//
//  DLog.swift
//  Pods
//
//  Created by Ellen Shapiro (Work) on 6/29/16.
//
//

import Foundation

/*
 This file facilitates log statements which will only print when the partner SDK singleton's `debugPrintInfo` flag is set to `true`.
 
 ALog will always log with details about the file, function, and line of the caller.
 
 Note: The message is the only required variable for any of these.
 */

/* A detailed log statement which will only print when in debug mode.
 
 - parameter message:  The message you wish to log out.
 */
//##SWIFTCLEAN_SKIP##
func DLog(@autoclosure message: () -> String,
//##SWIFTCLEAN_ENDSKIP##
    filename: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line) {
    if (ServerEnvironment.ShouldDebugPrintInfo) {
        detailedLog(message(), filename, function, line)
    } //Else, Do nothing out of debug mode
}

/**
 A detailed log statement which will always print.
 
 - parameter message:  The message you wish to log out.
 */
//##SWIFTCLEAN_SKIP##
func ALog(@autoclosure message: () -> String,
//##SWIFTCLEAN_ENDSKIP##
    filename: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line) {
    detailedLog(message(), filename, function, line)
}

/**
 Centralizes the detailed message formatting into a single method.
 
 - parameter message:  The message to print
 - parameter filename: The filename of the original caller.
 - parameter function: The function of the original caller
 - parameter line:     the line number of the original caller.
 */
private func detailedLog(message: String,
                         _ filename: StaticString,
                           _ function: StaticString,
                             _ line: UInt) {
    print("[\(filename.shp_lastPathComponent()):\(line)] \(function) - \(message)")
}

private extension StaticString {
    func shp_lastPathComponent() -> String {
        return (self.stringValue as NSString).lastPathComponent
    }
}
