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

public class VaultInfoResponse: HiveResponse {
    private var _did: String?
    private var _maxStorage: Int64?
    private var _fileUseStorage: Int64?
    private var _dbUseStorage: Int64?
    private var _modifyTime: Int64?
    private var _startTime: Int64?
    private var _endTime: Int64?
    private var _pricingUsing: String?
    private var _state: String?

    public override func mapping(map: Map) {
        super.mapping(map: map)
        _did <- map["vault_service_info.did"]
        _maxStorage <- map["vault_service_info.max_storage"]
        _fileUseStorage <- map["vault_service_info.file_use_storage"]
        _dbUseStorage <- map["vault_service_info.db_use_storage"]
        _modifyTime <- map["vault_service_info.modify_time"]
        _startTime <- map["vault_service_info.start_time"]
        _endTime <- map["vault_service_info.end_time"]
        _pricingUsing <- map["vault_service_info.pricing_using"]
        _state <- map["vault_service_info.state"]
    }
    
    public var did: String {
        get {
            return _did!
        }
    }
    
    public var maxStorage: Int64 {
        get {
            return _maxStorage!
        }
    }
    
    public var fileUseStorage: Int64 {
        get {
            return _fileUseStorage!
        }
    }
    
    public var dbUseStorage: Int64 {
        get {
            return _dbUseStorage!
        }
    }
    
    public var modifyTime: Int64 {
        get {
            return _modifyTime!
        }
    }

    public var startTime: Int64 {
        get {
            return _startTime!
        }
    }
    
    public var endTime: Int64 {
        get {
            return _endTime!
        }
    }
    
    public var pricingUsing: String {
        get {
            return _pricingUsing!
        }
    }
    
    public var state: String {
        get {
            return _state!
        }
    }

    public var isExisting: Bool {
        get {
            return self.state == "running"
        }
    }
}
