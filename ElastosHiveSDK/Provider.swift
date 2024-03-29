/*
* Copyright (c) 2021 Elastos Foundation
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

/// This class is used to fetch some possible information from remote hive node.
/// eg. version;
///     latest commit Id;
///     How many DID involved;
///     How many vault service running there;
///     How many backup service running there;
///     How much disk storage filled there;
///     etc.
public class Provider: ServiceEndpoint {
    public override init(_ context: AppContext) throws {
        try super.init(context) // TODO:
    }
    
    /// Create by the application context and the provider address.
    ///
    /// - parameters:
    ///   - context: The application context
    ///   - providerAddress: The provider address
    public override init(_ context: AppContext, _ providerAddress: String) throws {
        try super.init(context, providerAddress)
    }
}

