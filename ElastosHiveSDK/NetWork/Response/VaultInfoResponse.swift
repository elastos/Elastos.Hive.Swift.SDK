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
    private var _maxStorage: String?
    private var _fileUseStorage: String?
    private var _dbUseStorage: String?
    private var _modifyTime: String?
    private var _startTime: String?
    private var _endTime: String?
    private var _pricingUsing: String?
    private var _state: String?

    public override func mapping(map: Map) {
        _did <- map["did"]
        _maxStorage <- map["max_storage"]
        _fileUseStorage <- map["file_use_storage"]
        _dbUseStorage <- map["db_use_storage"]
        _modifyTime <- map["modify_time"]
        _startTime <- map["start_time"]
        _endTime <- map["end_time"]
        _pricingUsing <- map["pricing_using"]
        _state <- map["state"]
    }
    
    public var did: String {
        get {
            return _did!
        }
    }
    
    public var maxStorage: String {
        get {
            return _maxStorage!
        }
    }
    
    public var fileUseStorage: String {
        get {
            return _fileUseStorage!
        }
    }
    
    public var dbUseStorage: String {
        get {
            return _dbUseStorage!
        }
    }
    
    public var modifyTime: String {
        get {
            return _modifyTime!
        }
    }

    public var startTime: String {
        get {
            return _startTime!
        }
    }
    
    public var endTime: String {
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
    
}
