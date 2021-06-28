/*
 * Copyright (c) 2019 Elastos Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of self software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and self permission notice shall be included in all
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

public class QueryOptions: Mappable {
    private var _skip: Int64?
    private var _limit: Int64?
    private var _projection: Dictionary<String, Any>?
    private var _sort: [SortItem?]?
    private var _allowPartialResults: Bool?
    private var _returnKey: Bool?
    private var _showRecordId: Bool?
    private var _batchSize: Int64?
    
    public func setSkip(_ skip: Int64) -> QueryOptions {
        self._skip = skip;
        return self;
    }
    
    public func setLimit(_ limit: Int64) -> QueryOptions {
        self._limit = limit;
        return self;
    }
    
    public func setProjection(_ projection: Dictionary<String, Any>?) -> QueryOptions {
        self._projection = projection;
        return self;
    }
    
    public func setSort(_ sort: [SortItem]?) -> QueryOptions {
        self._sort = sort;
        return self;
    }
    
    public func setSort(_ sort: SortItem?) -> QueryOptions {
        self._sort = [sort];
        return self;
    }
    
    public func setAllowPartialResults(_ allowPartialResults: Bool?) -> QueryOptions {
        self._allowPartialResults = allowPartialResults;
        return self;
    }
    
    public func setReturnKey(_ returnKey: Bool) -> QueryOptions {
        self._returnKey = returnKey;
        return self;
    }
    
    public func setShowRecordId(_ showRecordId: Bool) -> QueryOptions {
        self._showRecordId = showRecordId;
        return self;
    }
    
    public func setBatchSize(_ batchSize: Int64?) -> QueryOptions {
        self._batchSize = batchSize;
        return self;
    }
    
    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        _skip <- map["skip"]
        _limit <- map["limit"]
        _projection <- map["projection"]
        _sort <- map["sort"]
        _allowPartialResults <- map["allow_partial_results"]
        _returnKey <- map["show_record_id"]
        _batchSize <- map["batch_size"]
    }
    
}


