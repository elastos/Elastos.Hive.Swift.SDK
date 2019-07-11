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

enum KEYCHAIN_KEY: String {
    typealias RawValue = String
    case ACCESS_TOKEN   = "access_token"
    case REFRESH_TOKEN  = "refresh_token"
    case EXPIRES_IN     = "expires_in"
    case EXPIRED_TIME   = "expiredTime"
    case REDIRECTURL    = "redirectURL"
    case SCOPE          = "scope"
    case CLIENT_ID      = "client_id"
}

let AUTHORIZATION_TYPE_CODE = "authorization_code"
let TOKEN_INVALID = "The token is invalid, please refresh token"


enum statusCode: Int {
    typealias RawValue = Int
    case ok  = 200
    case created = 201
    case accepted = 202
    case delete = 204
    case redirect_url = 302
    case unauthorized  = 401

}

