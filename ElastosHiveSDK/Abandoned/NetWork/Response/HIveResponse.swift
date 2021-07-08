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



public class HiveResponse: Mappable, HiveCheckValidProtocol{
    public var httpStatusCode: Int?
    public var status: String
    public var json: [String: Any] = [: ]

    required public init?(map: Map) {
        try! self.status = map.value("_status")
    }
    
    public func mapping(map: Map) {
        status <- map["_status"]
    }
    
    public func checkResponseVaild() throws {
        
    }
    
    public func getCount() -> Int64 {
        return 0
    }
    
    public func getString() -> String {
        return ""
    }
    
    public func getArray<T>(_ elementType: T.Type) -> Array<T> {
        return Array()
    }
}
