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

/// An entry class to connect with IPFS storage network
public class IPFSEntry {

    /// The UID representing user ID.
    var uid: String?

    /// The array of address of Hive IPFS nodes which provides IPFS service.
    let rpcAddrs: Array<String>

    /// The constructor with UID value
    ///
    /// - Parameter uid: The UID value
    /// - Parameter rpcAddrs: The array of addresses of IPFS nodes.
    public init(_ uid: String, _ rpcAddrs: Array<String>) {
        self.uid = uid
        self.rpcAddrs = rpcAddrs
    }

    /// The constructor with UID value
    ///
    /// - Parameter rpcAddrs: The array of addresses of IPFS nodes.
    public init(_ rpcAddrs: Array<String>) {
        self.uid = nil
        self.rpcAddrs = rpcAddrs
    }
}
