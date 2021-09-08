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

/// The backup controller is the wrapper class to access the backup module of the hive node.
public class BackupController {
    private var _connectionManager: ConnectionManager
    
    /// Create with the RPC connection.
    /// - Parameter serviceEndpoint: The ServiceEndpoint.
    public init(_ serviceEndpoint: ServiceEndpoint) {
        _connectionManager = serviceEndpoint.connectionManager!
    }
    
    /// Start the backup process which backups the data of the vault to other place.
    /// - Parameter credential: The credential for the hive node to access the backup service.
    /// - Throws: HiveError The error comes from the hive node.
    public func startBackup(_ credential: String) throws {
        try _ = _connectionManager.saveToNode(RequestParams(credential)).execute()
    }
    
    /// Restore the data of the vault from other place.
    /// - Parameter credential: The credential for the hive node to access the backup service.
    /// - Throws: HiveError The error comes from the hive node.
    public func restoreFrom(_ credential: String) throws {
        try _ = _connectionManager.restoreFromNode(RequestParams(credential)).execute()
    }
    
    /// Check the result of the backup process.
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: The result of the backup process.
    public func checkResult() throws -> BackupResultState {
        try _connectionManager.getState().execute(BackupResult.self).getStatusResult()
    }
}
