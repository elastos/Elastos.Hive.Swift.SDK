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

/// The condition is used for registering the script.
/// If the condition matches, the script will be executed normally.
public class Condition: NSObject, Mappable {    
    public var _type: String?
    public var _name: String?
    public var _body: HiveRootBody?

    public init(_ name: String?, _ type: String?, _ body: Any?) {
        self._name = name
        self._type = type
        if body != nil {
            self._body = body as? HiveRootBody
        }
    }
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        _type <- map["type"]
        _name <- map["name"]
        _body <- map["body"]
    }
    
    final var body: Any? {
        set {
            _body = newValue as? HiveRootBody
        }
        get {
            return _body
        }
    }
}


