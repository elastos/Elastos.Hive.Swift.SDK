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
    let HINT = "hint"

    var param: [String: Any] = [:]
    var _hint: Array<VaultIndex> = [ ]
    var _sort: Array<VaultIndex> = [ ]

    func setStringOption(_ name: String, _ value: String) -> T {
        param[name] = value
        return self as! T
    }

    func getStringOption(_ name: String) -> String? {
        return param[name] as? String
    }

    func setNumberOption(_ name: String, _ value: Int) -> T {
        param[name] = value
        return self as! T
    }

    func getNumberOption(_ name: String) -> Int? {
        return param[name] as? Int
    }
    
    func setBooleanOption(_ name: String, _ value: Bool) -> T {
        param[name] = value
        return self as! T
    }

    func getBooleanOption(_ name: String) -> Bool? {
        return param[name] as? Bool
    }

    func setArrayOption(_ name: String, _ value: Array<Any>) -> T {
        param[name] = value
        return self as! T
    }

    func getArrayOption(_ name: String) -> Array<Any>? {
        return param[name] as? Array<Any>
    }

    func setObjectOption(_ name: String, _ value: [String: Any]) -> T {
        param[name] = value
        return self as! T
    }

    func getObjectOption(_ name: String) -> [String: Any]? {
        return param[name] as? [String: Any]
    }

    func setObjectOption(_ name: String, _ value: Any) -> T {
        param[name] = value
        return self as! T
    }

    func getObjectOption(_ name: String, _ value: Any) -> Any {
        return param[name] as Any
    }

    func jsonSerialize() throws -> [String: Any] {
        try handleOtherParames()
        return param
    }

    func remove(_ key: String) {
        param.removeValue(forKey: key)
    }

    public func serialize() throws -> String {
        try handleOtherParames()
        let checker = JSONSerialization.isValidJSONObject(param)
        guard checker else {
            throw HiveError.jsonSerializationInvalidType(des: "HiveSDK serializate: JSONSerialization Invalid type in JSON.")
        }
        let data = try JSONSerialization.data(withJSONObject: param, options: [])
        guard let paramStr = String(data: data, encoding: .utf8) else {
            return ""
        }

        return paramStr
    }


    func handleOtherParames() throws {
        var hs: Array<[String: Any]> = [ ]
        try _hint.forEach { v in
            try hs.append(v.jsonSerialize())
        }
        if hs.count != 0 {
            _ = setArrayOption(HINT, hs)
        }
        hs.removeAll()
        try _sort.forEach{ v in
            try hs.append(v.jsonSerialize())
        }
        if hs.count != 0 {
            _ = setArrayOption("sort", hs)
        }
    }
}

