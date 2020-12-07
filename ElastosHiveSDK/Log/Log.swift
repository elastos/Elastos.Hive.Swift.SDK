/*
 * Copyright (c) 2019 Elastos Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import Foundation

public class Log {
    private static var logLevel = HiveLogLevel.Info

    public static func setLevel(_ level: HiveLogLevel) {
        logLevel = level
    }

    internal static func d(_ tag: String, _ format: String, _ args: CVarArg...) {
        if (logLevel >= HiveLogLevel.Debug) {
            let log = String(format: " D/\(tag):\(format)", arguments: args)
            NSLog(log)
        }
    }
    
    internal static func d(_ tag: String, _ arg: Any) {
        if (logLevel >= HiveLogLevel.Debug) {
            let log = "D/\(tag): "
            print(log, arg)
        }
    }

    internal static func i(_ tag: String, _ format: String, _ args: CVarArg...) {
        if (logLevel >= HiveLogLevel.Info) {
            let log = String(format: " I/\(tag):\(format)", arguments: args)
            NSLog(log)
        }
    }

    internal static func w(_ tag: String, _ format: String, _ args: CVarArg...) {
        if (logLevel >= HiveLogLevel.Warning) {
            let log = String(format: " W/\(tag):\(format)", arguments: args)
            NSLog(log)
        }
    }

    internal static func e(_ tag: String, _ format: String, _ args: CVarArg...) {
        if (logLevel >= HiveLogLevel.Error) {
            let log = String(format: " E/\(tag):\(format)", arguments: args)
            NSLog(log)
        }
    }
}
