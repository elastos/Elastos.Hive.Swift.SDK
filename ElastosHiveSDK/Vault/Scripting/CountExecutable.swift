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

/**
 * Client side representation of a back-end execution that runs a mongo "count" query
 * and returns the count of the result.
 */
public class CountExecutable: Executable {
    
    public init(_ name: String?, _ collectionName: String?, _ filter: Dictionary<String, Any>?, _ options: Dictionary<String, Any>?) {
        super.init(name, ExecutableType.COUNT, nil)
        super._body = CountBody(collectionName, filter, options)
    }
    
    public init(_ name: String?, _ collectionName: String?, _ filter: Dictionary<String, Any>?) {
        super.init(name, ExecutableType.COUNT, nil)
        super._body = CountBody(collectionName, filter, nil)
    }
    
    required public init?(map: Map) {
        fatalError("init(map:) has not been implemented")
    }
    
    public override func mapping(map: Map) {
        _type <- map["type"]
        _name <- map["name"]
    }

}

