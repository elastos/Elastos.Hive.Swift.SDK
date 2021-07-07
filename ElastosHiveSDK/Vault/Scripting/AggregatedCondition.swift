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

public enum AggregatedConditionType: String {
    case AND = "and"
    case OR = "or"
}

public class AggregatedCondition: Condition {

    public init(_ name: String?, _ type: String?, _ conditions: [Condition]?) {
        super.init(name, type, conditions)
    }
    
    public init(_ name: String?, _ type: String?) {
        super.init(name, type, nil)
    }
    
    public func setConditions(_ conditions: [Condition]?) -> AggregatedCondition {
        super.body = conditions == nil ? [] : conditions
        return self
    }
    
    public func appendCondition(_ condition: Condition?) -> AggregatedCondition {
        if condition == nil {
            return self
        }
        
        if super.body == nil {
            super.body = [condition]
        } else {
            var body = super.body as! [Condition]
//            body.append(condition)
        }
        return self
    }
    
    required public init?(map: Map) {
        fatalError("init(map:) has not been implemented")
    }
    
}

