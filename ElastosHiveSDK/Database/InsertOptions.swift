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

public class InsertOptions: Options<InsertOptions> {

    public init(_ iBypassDocumentValidation: Bool, _ iOrdered: Bool) {
        super.init()
        _ = bypassDocumentValidation(iBypassDocumentValidation)
        _ = ordered(iOrdered)
    }

    public init(_ iBypassDocumentValidation: Bool) {
        super.init()
        _ = bypassDocumentValidation(iBypassDocumentValidation)
    }

    public override init() { }

    public func bypassDocumentValidation(_ value: Bool) -> InsertOptions {

        return setBooleanOption("bypass_document_validation", value)
    }

    public var bypassDocumentValidation: Bool? {
        return getBooleanOption("bypass_document_validation")
    }

    public func ordered(_ value: Bool) -> InsertOptions {

        return setBooleanOption("ordered", value)
    }

    public var ordered: Bool? {
        return getBooleanOption("ordered")
    }

    public class func deserialize(_ content: String) throws -> InsertOptions {
        let data = content.data(using: String.Encoding.utf8)
        let paramars = try JSONSerialization.jsonObject(with: data!,
                                                        options: .mutableContainers) as? [String : Any] ?? [: ]
        let opt = InsertOptions();
        opt.param = paramars
        return opt
    }
}
