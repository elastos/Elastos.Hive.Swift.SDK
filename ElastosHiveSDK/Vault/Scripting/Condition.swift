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

public class Condition: NSObject, Mappable {
    private var _type: String?
    private var _name: String?
    private var _body: Any?
    
    public init(_ name: String, _ type: String, _ body: ScriptRootBody) {
        self._name = name
        self._type = type
        self._body = body
    }
    
    public var body: Any? {
        set {
            _body = newValue
        }
        get {
            return _body
        }
    }
    
    required public init?(map: Map) {

    }
    
    public func mapping(map: Map) {
        _type <- map["type"]
        _name <- map["name"]
        _body <- map["body"]
    }
    
//    public static let TYPE_AND = "and"
//    public static let TYPE_OR = "or"
//    public static let TYPE_QUERY_HAS_RESULTS = "queryHasResults"
}


