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

public enum CaseFirst {
    case UPPER
    case LOWER
    case OFF
}

public enum Strength: Int {
    case PRIMARY = 1
    case SECONDARY = 2
    case TERTIARY = 3
    case QUATERNARY = 4
    case IDENTICAL = 5
}

public enum Alternate {
    case NON_IGNORABLE
    case SHIFTED
}

public enum MaxVariable {
    case PUNCT
    case SPACE
}

public class Collation: Mappable {
    private var _locale: String?
    private var _caseLevel: Bool?
    private var _caseFirst: CaseFirst?
    private var _strength: Strength?
    private var _numericOrdering: Bool?
    private var _alternate: Alternate?
    private var _maxVariable: MaxVariable?
    private var _normalization: Bool?
    private var _backwards: Bool?
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        _locale <- map["locale"]
        _caseLevel <- map["caseLevel"]
        _caseFirst <- map["caseFirst"]
        _strength <- map["strength"]
        _numericOrdering <- map["numericOrdering"]
        _alternate <- map["alternate"]
        _maxVariable <- map["maxVariable"]
        _normalization <- map["normalization"]
        _backwards <- map["backwards"]
    }
    
    public init () {
        
    }
    
    public init(_ locale: String?, _ caseLevel: Bool?, _ caseFirst: CaseFirst?, _ strength: Strength?, _ numericOrdering: Bool?, _ alternate: Alternate?, _ maxVariable: MaxVariable?, _ normalization: Bool?, _ backwards: Bool?) {
        _locale = locale
        _caseLevel = caseLevel
        _caseFirst = caseFirst
        _strength = strength
        _numericOrdering = numericOrdering
        _alternate = alternate
        _maxVariable = maxVariable
        _normalization = normalization
    }

    public func locale(_ value: String?) -> Collation {
        _locale = value
        return self
    }

    public var getLocale: String? {
        return _locale
    }
    
    public func caseLevel(_ value: Bool?) -> Collation {
        _caseLevel = value
        return self
    }

    public var getCaseLevel: Bool? {
        return _caseLevel
    }

    public func caseFirst(_ value: CaseFirst?) -> Collation {
        _caseFirst = value
        return self
    }
    
    public var getCaseFirst: CaseFirst? {
        return _caseFirst
    }
    
    public func strength(_ value: Strength?) -> Collation {
        _strength = value
        return self
    }
    
    public var getStrength: Strength? {
        return _strength
    }

    public func numericOrdering(_ value: Bool?) -> Collation {
        _numericOrdering = value
        return self
    }
    
    public var numericOrdering: Bool? {
        return _numericOrdering
    }

    public func alternate(_ value: Alternate?) -> Collation {
        _alternate = value
        return self
    }

    public var alternate: Alternate? {
        return _alternate
    }
    
    public func maxVariable(_ value: MaxVariable?) -> Collation {
        _maxVariable = value
        return self
    }

    public var getMaxVariable: MaxVariable? {
        return _maxVariable
    }

    public func normalization(_ value: Bool?) -> Collation {
        _normalization = value
        return self
    }
    
    public var normalization: Bool? {
        return _normalization
    }
    
    public func backwards(_ value: Bool?) -> Collation {
        _normalization = value
        return self
    }
    
    public var backwards: Bool? {
        return _backwards
    }
}
