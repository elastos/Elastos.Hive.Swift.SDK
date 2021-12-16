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
 * Convenient class to store and serialize a sequence of executables.
 */
public class AggregatedExecutable: Executable {
    public var bodyArray: [FileDownloadExecutable]?
    
    init(_ name: String?) {
        super.init(name, ExecutableType.AGGREGATED, nil)
    }
    
    init(_ name: String?, _ executables: [Executable]?) {
        super.init(name, ExecutableType.AGGREGATED, executables)
    }
    
    public func appendExecutable(_ executable: Executable?) -> AggregatedExecutable? {
        if executable == nil || executable?._body == nil {
            return self
        }
        
        if super._body == nil {
            if executable is AggregatedExecutable {
                super._body = executable?._body
            }
            else {
                self.bodyArray = [executable] as? [FileDownloadExecutable]
            }
        } else {
            var es = super._body as! [Executable]
            if executable is AggregatedExecutable {
                es.append(contentsOf: executable!._body as! [Executable])
            } else {
                es.append(executable!)
            }
        }
        return self
    }
    
    required public init?(map: Map) {
        fatalError("init(map:) has not been implemented")
    }
    
    public override func mapping(map: Map) {
        _type <- map["type"]
        _name <- map["name"]
        if bodyArray != nil {
            bodyArray <- (map["body"], TestTransform())
        } else {
            _body <- map["body"]
        }
    }

}

open class TestTransform: TransformType {
    public func transformFromJSON(_ value: Any?) -> [FileDownloadExecutable]? {
        let vs = value as! [[String : Any]]
        var array: [FileDownloadExecutable] = []
        for i in vs {
            let f = FileDownloadExecutable(JSON: i, context: nil)
            array.append(f!)
        }
        
        return array
    }
    
    
    public typealias Object = [FileDownloadExecutable]
    public typealias JSON = [[String : Any]]
    
    public init() {}
    
    open func transformToJSON(_ value: [FileDownloadExecutable]?) -> [[String : Any]]? {
       
        return value?.toJSON()
    }
}

