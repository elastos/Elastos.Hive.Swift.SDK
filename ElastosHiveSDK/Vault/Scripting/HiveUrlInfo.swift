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

class HiveUrlInfo: NSObject {
    let HIVE_URL_PREFIX = "hive://"
    var targetDid: String
    var targetAppDid: String
    var scriptName: String
    var params: [String : Any]?

    init(_ hiveUrl: String) throws {
        if hiveUrl.prefix(7) != HIVE_URL_PREFIX {
            throw HiveError.InvalidParameterException("Invalid hive script url: no hive prefix.")
        }
        
        let parts = hiveUrl.suffix(hiveUrl.count - HIVE_URL_PREFIX.count).split(separator: "/")
        
        if (parts.count < 2) {
            throw HiveError.InvalidParameterException("Invalid hive script url: must contain at least one slash.")
        }

        let dids = parts[0].split(separator: "@")
        if (dids.count != 2) {
            throw HiveError.InvalidParameterException("Invalid hive script url: must contain two dids.")
        }
        let star = hiveUrl.count - (HIVE_URL_PREFIX.count + parts[0].count + 1)
        let values = hiveUrl.suffix(star).split(separator: "?")
        if (values.count != 2) {
            throw HiveError.InvalidParameterException("Invalid hive script url: must contain script name and params.")
        }
        targetDid = String(dids[0])
        targetAppDid = String(dids[1])
        scriptName = String(values[0])
        let data = String(values[1].suffix(values[1].count - 7)).data(using: String.Encoding.utf8)
        do {
            params = try JSONSerialization.jsonObject(with: data!,
                                                      options: .mutableContainers) as? [String : Any]
        }
        catch {
            throw HiveError.InvalidParameterException("Invalid parameters format in hive script url.")
        }
    }
}

