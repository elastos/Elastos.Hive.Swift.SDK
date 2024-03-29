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

/// The executable to update the documents of the mongo database.
public class UpdateExecutableBody: DatabaseBody {
    private var _filter: Dictionary<String, Any>?
    private var _update: Dictionary<String, Any>?
    private var _options: Dictionary<String, Any>?
    
    public init(_ collection: String?, _ filter: Dictionary<String, Any>?, _ update: Dictionary<String, Any>?, _ options: Dictionary<String, Any>?) {
        super.init(collection)
        _filter = filter
        _update = update
        _options = options
    }
    
    required init?(map: Map) {
        fatalError("init(map:) has not been implemented")
    }
    
    public override func mapping(map: Map) {
        super.mapping(map: map)
        _filter <- map["filter"]
        _update <- map["update"]
        _options <- map["options"]
    }
}

public class UpdateExecutable: Executable {
    public init(_ name: String?, _ collectionName: String?, _ filter: Dictionary<String, Any>?, _ update: Dictionary<String, Any>?, _ options: Dictionary<String, Any>?) {
        super.init(name, ExecutableType.UPDATE, UpdateExecutableBody(collectionName, filter, update, options))
    }
    
    public init(_ name: String, _ collectionName: String, _ filter: Dictionary<String, Any>?, _ update: Dictionary<String, Any>?) {
        super.init(name, ExecutableType.UPDATE, UpdateExecutableBody(collectionName, filter, update, nil))
    }
    
    required public init?(map: Map) {
        fatalError("init(map:) has not been implemented")
    }
    
    public override func mapping(map: Map) {
        super.mapping(map: map)
    }
}
