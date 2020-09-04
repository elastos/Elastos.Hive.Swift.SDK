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

let CONFIG = "hivesault.json"
let AUTH_URI = "https://accounts.google.com/o/oauth2/auth"
let TOKEN_URI = "https://oauth2.googleapis.com"
let SCOPE = "https://www.googleapis.com/auth/drive"
let SCOPES = "[https://www.googleapis.com/auth/drive]"
let DEFAULT_REDIRECT_URL = "localhost"
let DEFAULT_REDIRECT_PORT = 12345

let GRANT_TYPE_GET_TOKEN: String = "authorization_code"
let GRANT_TYPE_REFRESH_TOKEN: String = "refresh_token"
let TOKEN_INVALID = "The token is invalid, please refresh token."
let AUTHORIZE: String = "authorize"
let VAULT_CONFIG = "vault.json"
public let MAIN_NET_RESOLVER = "http://api.elastos.io:20606"

