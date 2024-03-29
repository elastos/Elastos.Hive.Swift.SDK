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

public class CountOptions: Mappable {
    private var _skip: Int64?
    private var _limit: Int64?
    private var _maxTimeMS: Int64?
    
    public init() {
        
    }
    
    public func setLimit(_ limit:Int64) -> CountOptions {
        _limit = limit
        return self
    }
    
    public func setSkip(_ skip:Int64) -> CountOptions {
        _skip = skip
        return self
    }
    
    public func setMaxTimeMS(_ maxTimeMS:Int64) -> CountOptions {
        _maxTimeMS = maxTimeMS
        return self
    }
    
//    public var skip: Int64 {
//        set {
//            _skip = newValue
//        }
//        get {
//            return _skip!
//        }
//    }
//
//    public var limit: Int64 {
//        set {
//            _limit = newValue
//        }
//        get {
//            return _limit!
//        }
//    }
//
//    public var maxTimeMS: Int64 {
//        set {
//            _maxTimeMS = newValue
//        }
//        get {
//            return _maxTimeMS!
//        }
//    }
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {

    }
}
