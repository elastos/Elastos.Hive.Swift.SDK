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

/// A base class inherited by upper application to define the routine to handle the
/// situation of failure or success when resovling the promise object.
open class HiveCallback<T> {

    /// The contructor.
    public init() {}

    /// The routine method that would be invoked when resolving the promise
    /// object with type of `T` succeed.
    /// - Parameter result: The object contained by the promise object
    /// - Returns: Void
    open func didSucceed(_ result: T) -> Void {}

    /// The routine method that would be invoked when resolving the promise
    /// object fails.
    /// - Parameter error: The specific error handle show the failure description of
    ///             resolving the promise object.
    open func runError(_ error: HiveError) -> Void {}
}
