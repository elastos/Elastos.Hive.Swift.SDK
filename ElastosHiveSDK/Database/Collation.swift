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

    public func locale(_ value: String) -> Collation {

        return setStringOption("locale", value)
    }

    public func caseLevel(_ value: Bool) -> Collation {

        return setBooleanOption("caseLevel", value)
    }

    public func caseFirst(_ value: CaseFirst) -> Collation {

        return setStringOption("caseFirst", value.description)
    }

    public func strength(_ value: Strength) -> Collation {

        return setNumberOption("strength", value.rawValue)
    }

    public func numericOrdering(_ value: Bool) -> Collation {

        return setBooleanOption("numericOrdering", value)
    }

    public func alternate(_ value: Alternate) -> Collation {

        return setStringOption("alternate", value.description)
    }

    public func maxVariable(_ value: MaxVariable) -> Collation {

        return setStringOption("maxVariable", value.description)
    }

    public func normalization(_ value: Bool) -> Collation {

        return setBooleanOption("normalization", value)
    }

    public func backwards(_ value: Bool) -> Collation {

        return setBooleanOption("backwards", value)
    }
}
