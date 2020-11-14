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

public enum CaseFirst: String {
    case UPPER = "UPPER"
    case LOWER = "LOWER"
    case OFF = "OFF"

    var description: String {

        switch self {
        case .UPPER: return "upper"
        case .LOWER: return "lower"
        case .OFF: return "off"
        }
    }
}

public enum Strength: Int {
    case PRIMARY = 1
    case SECONDARY
    case TERTIARY
    case QUATERNARY
    case IDENTICAL
}

public enum Alternate: String {
    case NON_IGNORABLE = "NON_IGNORABLE"
    case SHIFTED = "SHIFTED"

    var description: String {

        switch self {
        case .NON_IGNORABLE: return "non_ignorable"
        case .SHIFTED: return "shified"
        }
    }
}

public enum MaxVariable: String {
    case PUNCT = "PUNCT"
    case SPACE = "SPACE"

    var description: String {

        switch self {
        case .PUNCT: return "punct"
        case .SPACE: return "space"
        }
    }
}

public class Collation: Options<Collation> {
    private let LOCALE = "locale"
    private let CASELEVEL = "caseLevel"
    private let CASEFIRST = "caseFirst"
    private let STRENGTH = "strength"
    private let NUMERICORDERING = "numericOrdering"
    private let ALTERANTE = "alternate"
    private let MAXVARIABLE = "maxVariable"
    private let NORMALIZATION = "normalization"
    private let BACKWARDS = "backwards"
    private var _caseFirst: CaseFirst?
    private var _strength: Strength?
    private var _alternate: Alternate?
    private var _maxVariable: MaxVariable?

    public init(_ cLocale: String, _ cCaseLevel: Bool, _ cCaseFirst: CaseFirst, _ cStrength: Strength, _ cNumericOrdering: Bool, _ cAlternate: Alternate, _ cMaxVariable: MaxVariable, _ cNormalization: Bool, _ cBackwards: Bool) {
        super.init()
        _ = locale(cLocale)
        _ = caseLevel(cCaseLevel)
        _ = caseFirst(cCaseFirst)
        _ = strength(cStrength)
        _ = numericOrdering(cNumericOrdering)
        _ = alternate(cAlternate)
        _ = maxVariable(cMaxVariable)
        _ = normalization(cNormalization)
        _ = backwards(cBackwards)
    }

    public override init() {
        
    }

    public func locale(_ value: String) -> Collation {

        return setStringOption(LOCALE, value)
    }

    public var locale: String? {
        return getStringOption(LOCALE)
    }

    public func caseLevel(_ value: Bool) -> Collation {

        return setBooleanOption(CASELEVEL, value)
    }

    public var caseLevel: Bool? {
        return getBooleanOption(CASELEVEL)
    }

    public func caseFirst(_ value: CaseFirst) -> Collation {
        _caseFirst = value
        return setStringOption(CASEFIRST, value.description)
    }

    public var caseFirst: CaseFirst? {
        return _caseFirst
    }

    public func strength(_ value: Strength) -> Collation {
        _strength = value
        return setNumberOption(STRENGTH, value.rawValue)
    }

    public var strength: Strength? {
        return _strength
    }

    public func numericOrdering(_ value: Bool) -> Collation {

        return setBooleanOption(NUMERICORDERING, value)
    }

    public var numericOrdering: Bool? {
        return getBooleanOption(NUMERICORDERING)
    }

    public func alternate(_ value: Alternate) -> Collation {
        _alternate = value
        return setStringOption(ALTERANTE, value.description)
    }

    public var alternate: Alternate? {
        return _alternate
    }

    public func maxVariable(_ value: MaxVariable) -> Collation {
        _maxVariable = value
        return setStringOption(MAXVARIABLE, value.description)
    }

    public var maxVariable: MaxVariable? {
        return _maxVariable
    }

    public func normalization(_ value: Bool) -> Collation {

        return setBooleanOption(NORMALIZATION, value)
    }

    public var normalization: Bool? {
        return getBooleanOption(NORMALIZATION)
    }

    public func backwards(_ value: Bool) -> Collation {

        return setBooleanOption(BACKWARDS, value)
    }

    public var backwards: Bool? {
        return getBooleanOption(BACKWARDS)
    }

    public class func deserialize(_ content: [String: Any]) -> Collation {
        let collation = Collation();
        collation.param = content
        let paramJson = JSON(content)
        let caseF = paramJson["caseFirst"].stringValue
        if caseF != "" {
            collation._caseFirst = CaseFirst(rawValue: caseF)
        }

        let stre = paramJson["strength"].stringValue
        if stre != "" {
            collation._strength = Strength(rawValue: paramJson["strength"].intValue)
        }

        let alter = paramJson["alternate"].stringValue
        if alter != "" {
            collation._alternate = Alternate(rawValue: alter)
        }
        let max = paramJson["maxVariable"].stringValue
        if max != "" {
            collation._maxVariable = MaxVariable(rawValue: max)
        }

        return collation
    }
}
