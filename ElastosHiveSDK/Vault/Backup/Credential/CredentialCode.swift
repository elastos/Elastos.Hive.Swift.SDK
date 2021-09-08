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

/// The credential code is used for the backup of the vault data.
public class CredentialCode {
    private var _targetServiceDid: String
    private var _jwtCode: String?
    private var _remoteResolver: CodeFetcher
    private var _storage: DataStorage
    
    /// Create the credential code by service end point and the backup context.
    /// - Parameters:
    ///   - endpoint: The service end point.
    ///   - context: The backup context.
    public init(_ endpoint: ServiceEndpoint, _ context: BackupContext) {
        _targetServiceDid = context.getParameter("targetDid")!
        let remoteResolver: CodeFetcher = RemoteResolver(endpoint, context, _targetServiceDid, context.getParameter("targetHost")!)
        _remoteResolver = LocalResolver(endpoint, remoteResolver)
        _storage = endpoint.getStorage()
    }
    
    /// Get the token of the credential code.
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: The token of the credential code.
    public func getToken() throws -> String? {
        if _jwtCode != nil {
            return _jwtCode
        }
        
        _jwtCode = try restoreToken()
        if _jwtCode == nil {
            _jwtCode = try _remoteResolver.fetch()
        }
        
        if _jwtCode != nil {
            try saveToken(_jwtCode!)
        }
        
        return _jwtCode
    }
    
    private func restoreToken() throws -> String? {
        return try _storage.loadBackupCredential(_targetServiceDid)
    }

    private func saveToken(_ jwtCode: String) throws {
        try _storage.storeBackupCredential(_targetServiceDid, _jwtCode!);
    }

}
