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

public class Options<T>: NSObject {

    private var param: [String: Any] = [:]
    func setStringOption(_ name: String, _ value: String) -> T {
        param[name] = value
        return self as! T
    }

    func setNumberOption(_ name: String, _ value: Int) -> T {
        param[name] = value
        return self as! T
    }
    
    func setBooleanOption(_ name: String, _ value: Bool) -> T {
        param[name] = value
        return self as! T
    }

    func setArrayOption(_ name: String, _ value: Array<Any>) -> T {
        param[name] = value
        return self as! T
    }

    func setObjectOption(_ name: String, _ value: [String: Any]) -> T {
        param[name] = value
        return self as! T
    }

    func setObjectOption(_ name: String, _ value: Any) -> T {
        param[name] = value
        return self as! T
    }

    func serialize() throws -> String {
        let data = try JSONSerialization.data(withJSONObject: param, options: [])
        guard let paramStr = String(data: data, encoding: .utf8) else {
            return ""
        }

        return paramStr
    }

    func remove(_ key: String) {
        param.removeValue(forKey: key)
    }
}
