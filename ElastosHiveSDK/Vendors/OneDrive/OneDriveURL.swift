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

enum ONEDRIVE_SUB_Url: String {
    case ONEDRIVE_AUTHORIZE   = "authorize"
    case ONEDRIVE_LOGOUT      = "/logout"
    case ONEDRIVE_TOKEN       = "/token"
}

class OneDriveURL {
    internal static let AUTH = "https://login.microsoftonline.com/common/oauth2/v2.0"
    internal static let API  = "https://graph.microsoft.com/v1.0/me/drive"
    internal static let ROOT = "/root"

    private let pathName: String
    private let extName : String?

    convenience init(_ pathName: String) {
        self.init(pathName, nil)
    }

    init(_ pathName: String, _ extName: String?) {
        self.pathName = pathName
        self.extName  = extName
    }

    func compose() -> String {
        if pathName == "/" && extName == nil {
            return "\(OneDriveURL.API)\(OneDriveURL.ROOT)"
        }

        if pathName == "/" && extName != nil {
            return "\(OneDriveURL.API)\(OneDriveURL.ROOT)/\(extName!)"
        }

        if pathName != "/" && extName == nil {
            let path: String = pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            return "\(OneDriveURL.API)\(OneDriveURL.ROOT):\(path)"
        }

        let path: String = pathName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        return "\(OneDriveURL.API)\(OneDriveURL.ROOT):\(path):/\(extName!)"
    }
}
