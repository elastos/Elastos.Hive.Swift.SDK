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


public class FindOptions: Mappable {
    private var _projection: Dictionary<String, Any>?
    private var _skip: Int64?
    private var _sort: Array<Dictionary<String, Any>>?
    private var _allowPartialResults: Bool?
    private var _batchSize: Int?
    private var _returnKey: Bool?
    private var _showRecordId: Bool?
    
    public init () {
        
    }

    public var projection: Dictionary<String, Any> {
        set {
            _projection = newValue
        }
        get {
            return _projection!
        }
    }
    
    public var skip: Int64 {
        set {
            _skip = newValue
        }
        get {
            return _skip!
        }
    }
    
    public var sort: Array<Dictionary<String, Any>> {
        set {
            _sort = newValue
        }
        get {
            return _sort!
        }
    }
    
    public var allowPartialResults: Bool {
        set {
            _allowPartialResults = newValue
        }
        get {
            return _allowPartialResults!
        }
    }

    public var batchSize: Int {
        set {
            _batchSize = newValue
        }
        get {
            return _batchSize!
        }
    }

    public var returnKey: Bool {
        set {
            _returnKey = newValue
        }
        get {
            return _returnKey!
        }
    }
    
    public var showRecordId: Bool {
        set {
            _showRecordId = newValue
        }
        get {
            return _showRecordId!
        }
    }

    public required init?(map: Map) {
            
    }
    
    public func mapping(map: Map) {
        _projection <- map["projection"]
        _skip <- map["skip"]
        _sort <- map["sort"]
        _allowPartialResults <- map["allow_partial_results"]
        _batchSize <- map["batch_size"]
        _returnKey <- map["return_key"]
        _showRecordId <- map["show_record_id"]
    }
}
