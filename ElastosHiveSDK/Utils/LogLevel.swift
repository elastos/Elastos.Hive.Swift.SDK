import Foundation

/**
 Hive log level to control or filter log output
 */
@objc(HiveLogLevel)
internal enum HiveLogLevel : Int, CustomStringConvertible {

    /// Log level None
    /// Indicate disable log output.
    case None = 0

    /// Log level fatal
    /// Indicate output log with level 'Fatal' only.
    case Fatal = 1

    /// Log level error.
    /// Indicate output log above 'Error' level.
    case Error = 2

    /// Log level warning.
    /// Indicate output log above 'Warning' level.

    case Warning = 3

    /// Log level info.
    /// Indicate output log above 'Info' level.
    case Info = 4

    /// Log level debug.
    /// Indicate output log above 'Debug' level.
    case Debug = 5

    /// Log level trace.
    /// Indicate output log above 'Trace' level.
    case Trace = 6

    /// Log level verbose.
    /// Indicate output log above 'Verbose' level.
    case Verbose = 7

    internal static func format(_ level: HiveLogLevel) -> String {
        var value : String

        switch level {
        case None:
            value = "None"
        case Fatal:
            value = "Fatal"
        case Error:
            value = "Error"
        case Warning:
            value = "Warning"
        case Info:
            value = "Info"
        case Debug:
            value = "Debug"
        case Trace:
            value = "Trace"
        case Verbose:
            value = "Verbose"
        }
        return value
    }

    public var description: String {
        return HiveLogLevel.format(self)
    }
}

internal func >= (left: HiveLogLevel, right: HiveLogLevel) -> Bool {
    return (left.rawValue >= right.rawValue)
}
