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

public class QueryHasResultConditionBody: HiveRootBody {
    private var _collection: String?
    private var _filter: Dictionary<String, String>?
    private var _options: QueryHasResultConditionOptions?
    
    public init(_ collectionName: String?, _ filter: Dictionary<String, String>?, _ options: QueryHasResultConditionOptions?) {
        super.init()
        _collection = collectionName
        _filter = filter
        _options = options
    }
    
    public required init?(map: Map) {
        fatalError("init(map:) has not been implemented")
    }
    
    public override func mapping(map: Map) {
        _collection <- map["collection"]
        _filter <- map["filter"]
        _options <- map["options"]
    }
}

public class QueryHasResultConditionOptions {
    private var _skip: Int64?
    private var _limit: Int64?
    private var _maxTimeMS: Int64?
    
    public init(_ skip: Int64?, _ limit: Int64?, _ maxTimeMS: Int64?) {
        _skip = skip
        _limit = limit
        _maxTimeMS = maxTimeMS
    }
}

/**
 * Vault script condition to check if a database query returns results or not.
 * This is a way for example to check if a user is in a group, if a message contains comments, if a user
 * is in a list, etc.
 */
public class QueryHasResultCondition: Condition {
    private static let TYPE: String = "queryHasResults"
    
    public init(_ name: String?, _ collectionName: String?, _ filter: Dictionary<String, String>?, _ options: Any?) {
        super.init(name, QueryHasResultCondition.TYPE, QueryHasResultConditionBody(collectionName, filter, (options as! QueryHasResultConditionOptions)))
    }
    
    public init(_ name: String?, _ collectionName: String?, _ filter: Dictionary<String, String>?) {
        super.init(name, QueryHasResultCondition.TYPE, QueryHasResultConditionBody(collectionName, filter, nil))
    }
    
    required public init?(map: Map) {
        fatalError("init(map:) has not been implemented")
    }
    
    public override func mapping(map: Map) {
        super.mapping(map: map)
    }
}
