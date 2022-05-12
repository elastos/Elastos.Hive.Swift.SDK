/*
* Copyright (c) 2022 Elastos Foundation
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

/// This contains the details of the backup service.
public class AppInfo: Mappable {
    public var _name: String?
    public var _developerDid: String?
    public var _iconUrl: String?
    public var _userDid: String?
    public var _appDid: String?
    public var _usedStorageSize: Int?

    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        _name <- map["name"]
        _developerDid <- map["developer_did"]
        _iconUrl <- map["icon_url"]
        _userDid <- map["user_did"]
        _appDid <- map["app_did"]
        _usedStorageSize <- map["used_storage_size"]
    }
    
    public var name: String? {
        return _name
    }

    public var developerDid: String? {
        return _developerDid
    }
    
    public var iconUrl: String? {
        return _iconUrl
    }

    public var userDid: String? {
        return _userDid
    }

    public var appDid: String? {
        return _appDid
    }

    public var usedStorageSize: Int? {
        return _usedStorageSize
    }
}
