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
import ObjectMapper

public class AuthToken: NSObject, Mappable{
    public static let backupType: String = "backup"
    
    var _accessToken: String
    var _expiresTime: Int64
    var _tokenType: String
    
    init(_ accessToken: String, _ expiresTime: Int64, _ tokenType: String) {
        self._accessToken = accessToken
        self._expiresTime = expiresTime
        self._tokenType = tokenType
    }

    public var accessToken: String {
        return _accessToken
    }
    public var expiresTime: Int64 {
        return _expiresTime
    }
    public var tokenType: String {
        return _tokenType
    }
    
    public var canonicalizedAccessToken: String {
        return _tokenType + " " + accessToken
    }
    
    public var isExpired: Bool {
        return Int64(Date().timeIntervalSince1970) >= expiresTime
    }
    
    public required init?(map: Map) {
        try! self._accessToken = map.value("accessToken")
        try! self._expiresTime = map.value("expiresTime")
        try! self._tokenType = map.value("tokenType")
    }
    
    public func mapping(map: Map) {
        _accessToken <- map["accessToken"]
        _expiresTime <- map["expiresTime"]
        _tokenType <- map["tokenType"]
    }
}
