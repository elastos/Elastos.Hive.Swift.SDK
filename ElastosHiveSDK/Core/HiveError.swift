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

public enum HiveError: Error {
    case insufficientParameters(des: String?)
    case invalidatedBuilder(des: String?)
    case failue(des: String?)
    case IllegalArgument(des: String?)
    case no_rpc_node_available(des: String?)
    case netWork(des: Error?)
    case failues(des: Dictionary<String, Any>?)
    case unsupportedOperation(des: String?)
}

extension HiveError {

   public static func description(_ error: HiveError) -> String {
        switch error {
        case .failue(let des):
            return des ?? "Operation failed"
        case .insufficientParameters(let des):
            return des ?? ""
        case .invalidatedBuilder(let des):
            return des ?? ""
        case .IllegalArgument(let des):
            return des ?? ""
        case .no_rpc_node_available(let des):
            return des ?? ""
        case .netWork(let des):
            return des.debugDescription
        case .failues(let des):
            let data = try? JSONSerialization.data(withJSONObject: des as Any, options: [])
            guard data != nil else {
                return ""
            }
            return String(data: data!, encoding: String.Encoding.utf8)!
        case .unsupportedOperation(let des):
            return des ?? ""
        }
    }
}

