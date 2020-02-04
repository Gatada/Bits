//
//  Log.swift
//  JBits
//
//  Created by Johan Basberg on 16/12/2019.
//  Copyright © 2019 Johan Basberg. All rights reserved.
//

import Foundation
import os.log


/// Logging related helpers, details and types used by `xc_log()`.
public enum Log {
    
    // MARK: - Properties
    
    /// The logging category to be used for the log message.
    ///
    /// The category will determine if the message is printed only
    /// in the Xcode console or also output in the Terminal for the
    /// given process.
    public enum Category: String {
        
        /// Used for general and usually temporary output.
        ///
        /// Logs of this kind are usually added to track execution flow or show state information
        /// that is not useful once the feature is fully developed or refactored. Logs in this category
        /// are usually removed before the code is committed.
        case `default`
        
        /// Used to log state information.
        ///
        /// Info logs will usually be left in the application even
        /// after the feature is fully implemented.
        case info
        
        /// Used for debug related state expectations during development.
        ///
        /// An error marks the result of a bug. Errors are hard to catch,
        /// which is why debug logs are some times used.
        ///
        /// When the wrong variable is used or the design is incorrectly
        /// implemented by the developer the result is an error. If a variable
        /// is received with unexpected or invalid values an error occurs.
        ///
        /// Ideally messages using this log category should be self-contained and
        /// their validity verifiable. In other words, include your expectation and the
        /// actual value:
        ///
        /// `Expecting 5 == 4`
        ///
        /// Debug output should usually be removed after the feature has been
        /// fully implemented.
        case debug
        
        /// Used for to log unintended behaviour caused by bugs.
        ///
        /// When an application executes code that were not suppose to be
        /// reached, you experience a fault. A fault could be a non-critical anomaly
        /// that emerges from refactoring.
        ///
        /// Fault logs are useful for the inevitable refactoring and should
        /// therefore not be removed.
        case fault
        
        /// Used to log a failure to fulfill performance requirements.
        ///
        /// Tests can be used to prevent failure. Assertions can also be
        /// used to catch or inform the developer about failures even
        /// before testing begins.
        case failure
        
        /// A suitable emoji that marks the beginning of a log message.
        var emoji: StaticString {
            switch self {
            case .default:
                return "📎"
            case .info:
                return "ℹ️"
            case .debug:
                return "🧑🏼‍💻"
            case .fault:
                return "⁉️"
            case .failure:
                return "❌"
            }
        }
        
        /// Mapping a Category to a suitable OSLog type.
        var osLogEquivalent: OSLog {
            switch self {
            case .default:
                return OSLog.default
            case .info:
                return OSLog.info
            case .debug:
                return OSLog.debug
            case .fault:
                return OSLog.fault
            case .failure:
                return OSLog.failure
            }
        }
        
        /// Maps the Category to a suitable OSLogType.
        ///
        /// Only some of the existing OSLogTypes seem to appear in
        /// the Console, which is handled by this mapping.
        var osLogTypeEquivalent: OSLogType {
            switch self {
            case .default, .info, .debug:
                return OSLogType.default
            case .fault:
                return OSLogType.fault
            case .failure:
                return OSLogType.error
            }
        }
    }

    /// The default subsystem used when logging.
    public static let mainBundle = Bundle.main.bundleIdentifier!


    // MARK: - Private Helpers

    /// Prints the messages received in the Xcode debug area.
    ///
    /// All the messages are printed on a single line, separated with a space character,
    /// and at the end of the message the terminator is appended.
    ///
    /// - Parameters:
    ///   - messages: An array of strings, each resulting in a message sent to the OS logging system.
    ///   - terminator: The string appended to the message. By default this is `\n`.
    ///   - log: Use this to group logs into a suitable `Category`.
    ///   - subsystem: A string describing a subsystem. Default value is the main bundle identifier.
    private static func debugAreaPrint(_ messages: [String], terminator: String, log: Log.Category, subsystem: String) -> Bool {
        print("\(log.emoji) \(timestamp()) \(log) \(subsystem) –", terminator: "")
        for message in messages {
            print(" " + message, terminator: "")
        }
        print("", terminator: terminator)
        return true
    }
    
    
    /// Creates a timestamp used as part of the temporary logging in the debug area.
    static func timestamp() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        return dateFormatter.string(from: date)
    }
    

    /// Use to temporary log events in the Xcode debug area.
    ///
    /// These calls will be completely removed for release or any non-debugging build.
    ///
    /// - Parameters:
    ///   - messages: A variadic parameter of strings to print in the debug area.
    ///   - log: Use this to group logs into a suitable `Category`.
    ///   - subsystem: A string describing a subsystem. Default value is the main bundle identifier.
    ///   - terminator: The string appended to the end of the messages. By default this is `\n`.
    public static func da(_ messages: String..., log: Log.Category, subsystem: String = Log.mainBundle, terminator: String = "\n") {
        assert(Log.debugAreaPrint(messages, terminator: terminator, log: log, subsystem: subsystem))
    }

    
    /// Send one or more messages to both the Xcode debug area and the OS logging system.
    ///
    /// The messages received by the logging system are retained in a ring buffer managed
    /// by the operating system. All received log messages can be exported on the device,
    /// however the file is usually quite large (probably too large to send by email).
    ///
    /// To review the log messages in real time please launch the Console app on your Mac.
    /// Make sure you have selected the correct device when browsing the messages.
    ///
    /// - Important:
    /// Nothing will be seen in the debug area or the OS logging system if `OS_ACTIVITY_MODE` is disabled
    /// in the the build scheme for the target.
    ///
    /// - Parameters:
    ///   - messages: A variadic parameter of strings to print in the debug area.
    ///   - log: Use this to group logs into a suitable `Category`.
    ///   - subsystem: A string describing a subsystem. Default value is the main bundle identifier.
    ///   - terminator: The string appended to the end of the messages. By default this is `\n`.
    public static func os(_ messages: String..., log: Log.Category, subsystem: String = Log.mainBundle, terminator: String = "\n") {
        var resultingMessage = ""
        for message in messages {
            resultingMessage += " \(message)"
        }
        os_log("%{private}@", log: log.osLogEquivalent, type: log.osLogTypeEquivalent, "\(log.emoji) \(subsystem) -\(resultingMessage)\(terminator)")
    }

}


// MARK: - Custom OSLog Categories

/// This extension uses the bundle identifier of the app and
/// creates a static instance for each category.
extension OSLog {

    private static var subsystem = Bundle.main.bundleIdentifier!
    
    /// The `default` log level used for general output.
    ///
    /// Logs of this kind are usually temporary, and are therefore
    /// removed after the feature has been completely implemented.
    static let `default` = OSLog(subsystem: subsystem, category: "default")

    /// Used to log state information.
    ///
    /// This is useful to log details could help improve the application, like the
    /// range of values used in a graph.
    ///
    /// Ensure the logged information do not violate any privacy policies, terms or
    /// conditions.
    static let info = OSLog(subsystem: subsystem, category: "info")

    /// Used to log debug information, like state expectations and values.
    ///
    /// Ideally messages using this log category should be self-contained and
    /// their validity verifiable. In other words, include your expectation and the
    /// actual value:
    ///
    /// ```
    /// Expecting 5 - Received 4
    ///
    /// ```
    static let debug = OSLog(subsystem: subsystem, category: "debug")
    
    /// A `fault` indicates unintended behaviour usually as a result
    /// of an error.
    ///
    /// Use this category when the application executes code that were not suppose to be
    /// reached, you experience a fault. A fault could be a non-critical anomaly
    /// that emerges from refactoring.
    static let fault = OSLog(subsystem: subsystem, category: "fault")
     
    /// A failure is the formal inability to fulfill performance requirements.
    ///
    /// Tests can be used to prevent failure. Assertions can also be
    /// used to catch or inform the developer about failures even
    /// before testing begins.
    static let failure = OSLog(subsystem: subsystem, category: "failure")
    
}
