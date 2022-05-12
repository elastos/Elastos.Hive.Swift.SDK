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
import PromiseKit

/// The AboutController is for getting the basic information of the hive node.
public class AboutController {
    private var _connectionManager: ConnectionManager
    
    /// Create the about controller by the RPC connection.
    /// - Parameter serviceEndpoint: connection The connection instance.
    public init(_ serviceEndpoint: ServiceEndpoint) {
        _connectionManager = serviceEndpoint.connectionManager!
    }
    
    /// Get the version of the hive node.
    /// - Throws: HiveError The exception shows the error from the request.
    /// - Returns: the version
    public func getNodeVersion() throws -> NodeVersion {
        return try _connectionManager.version().execute(NodeVersion.self)
    }
    
    /// Get the commit id of the github of the hive node.
    /// - Throws: HiveError The exception shows the error from the request.
    /// - Returns: The commit id.
    public func getCommitId() throws -> String? {
        return try _connectionManager.commitId().execute(CommitHash.self).commitId
    }
    
    /// Get the information of the hive node.
    /// - Returns: The information of the hive node.
    public func getNodeInfo() throws -> NodeInfo {
      return try _connectionManager.info().execute(NodeInfo.self)
    }
}
