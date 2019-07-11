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

///  The `AuthToken` object is a property bag for storing information needed to make authentication requests.
///  @see https://dev.onedrive.com/auth/readme.htm.
class AuthToken: NSObject {

    ///  The length of the access token expires
    var expiredIn: Int64 = 0

    ///  The access token for the user.
    var accessToken: String = ""

    /// The refresh token to when refreshing the access token.
    var refreshToken: String = ""

    ///  The time stamp indicating when the access token expires
    var expiredTime: String = ""

    /// Check access token isExpired
    /// - Returns:  Returns `true` if expired, `false` otherwise.
    func isExpired() -> Bool {
        return Timestamp.isAfter(expiredTime)
    }
}
