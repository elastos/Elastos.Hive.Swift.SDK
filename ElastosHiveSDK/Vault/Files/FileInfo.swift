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
 * The class to represent the information of File or Folder.
 */
public class FileInfo: Mappable {
    private var _name: String?
    private var _isFile: Bool?
    private var _size: Int?
    private var _created : Int64?
    private var _updated : Int64?

    public var name: String? {
        return _name
    }

    public var isFile: Bool? {
        return _isFile
    }

    public var size: Int? {
        return _size
    }

//    public var created: Date? {
//        return Date(timeIntervalSinceReferenceDate: _created * 1000)
//    }
//    
//    public var updated: Date? {
//        return Date(timeIntervalSinceReferenceDate: _updated * 1000)
//    }
    
    required public init?(map: Map) {

    }
    
    public func mapping(map: Map) {
        _name <- map["name"]
        _isFile <- map["is_file"]
        _size <- map["size"]
        _created <- map["created"]
        _updated <- map["updated"]
    }
}
