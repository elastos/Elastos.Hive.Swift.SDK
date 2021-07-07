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

public class DeleteOptions: Mappable {
    private var _collation: Collation?
    private var _hint: [HiveIndex]?
    
    public init(_ collation: Collation, _ hint: HiveIndex?) {
        
    }

    public var collation: Collation? {
        return _collation
    }
    
    public func collation(_ value: Collation?) -> DeleteOptions {
        _collation = value
        return self
    }
    
    public func hint(_ value: HiveIndex?) -> DeleteOptions {
        if value == nil {
            _hint = nil
        } else {
            if _hint == nil {
                _hint = []
            }
            _hint?.append(value!)
        }
        return self
    }
    
    public func hint(_ value: [HiveIndex]?) -> DeleteOptions {
        if value == nil {
            _hint = nil
        } else {
            if _hint == nil {
                _hint = []
            }
            _hint?.append(contentsOf: value!)
        }
        return self
    }
    
    public var hint: Array<HiveIndex>? {
        return _hint
    }
        
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {

    }
    
    
}
