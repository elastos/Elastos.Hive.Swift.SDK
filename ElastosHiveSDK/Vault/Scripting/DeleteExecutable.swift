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

/// Convenient class to delete the documents from the collection.
public class DeleteExecutableBody: DatabaseBody {
    private var _filter: Dictionary<String, Any>?
    
    public init(_ collection: String?, _ filter: Dictionary<String, Any>?) {
        super.init(collection)
        _filter = filter
    }
    
    required init?(map: Map) {
        fatalError("init(map:) has not been implemented")
    }
}

public class DeleteExecutable: Executable {
    public init(_ name: String?, _ collectionName: String?, _ filter: Dictionary<String, Any>?) {
        super.init(name, ExecutableType.DELETE, nil)
        self._body = DeleteExecutableBody(collectionName, filter)
    }
    
    public init(_ name: String?, _ collectionName: String?) {
        super.init(name, ExecutableType.DELETE, nil)
        self._body = DeleteExecutableBody(collectionName, nil)
    }
    
    required public init?(map: Map) {
        fatalError("init(map:) has not been implemented")
    }
}
