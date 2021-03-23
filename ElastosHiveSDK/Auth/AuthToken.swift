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

public class AuthToken: NSObject {
    var _accessToken: String
    public var accessToken: String {
        return _accessToken
    }
    var _expiresTime: Int
    public var expiresTime: Int {
        return _expiresTime
    }
    var _tokenType: String
    public var tokenType: String {
        return _tokenType
    }
    
    public var canonicalizedAccessToken: String {
        return _tokenType + " " + accessToken
    }
    
    init(_ accessToken: String, _ expiresTime: Int, _ tokenType: String) {
        self._accessToken = accessToken
        self._expiresTime = expiresTime
        self._tokenType = tokenType
    }
    
    public var isExpired: Bool {
        return Int(Date().timeIntervalSince1970) >= expiresTime
    }
}
