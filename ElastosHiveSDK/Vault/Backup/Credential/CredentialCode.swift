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
    private var _endpoint: ServiceEndpoint
    private var _storageKay: String

    /// Create the credential code by service end point and the backup context.
    /// - Parameters:
    ///   - endpoint: The service end point.
    ///   - context: The backup context.
    public init(_ endpoint: ServiceEndpoint, _ context: BackupContext) {
        self._endpoint = endpoint
        _targetServiceDid = context.getParameter("targetDid")!
        let remoteResolver: CodeFetcher = RemoteResolver(endpoint, context, _targetServiceDid, context.getParameter("targetHost")!)
        _remoteResolver = LocalResolver(endpoint, remoteResolver)
        _storage = endpoint.getStorage()
        self._storageKay = ""
    }
    
    private func getStorageKey() -> String {
        if (self._storageKay == "") {
            let userDid = (self._endpoint.userDid != nil) ? self._endpoint.userDid! : ""
            let sourceDid = (self._endpoint.serviceInstanceDid != nil) ? self._endpoint.serviceInstanceDid! : ""
            let key = userDid + ";" + sourceDid + ";" + _targetServiceDid
            self._storageKay = key.sha256
        }
        return self._storageKay
    }

    
    /// Get the token of the credential code.
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: The token of the credential code.
    public func getToken() throws -> String? {
        if _jwtCode != nil {
            return _jwtCode
        }
        
        if (self._endpoint.serviceInstanceDid == nil) {
            // TODO: throws
                try self._endpoint.refreshAccessToken()
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
        let key = self.getStorageKey()
        let cred = try _storage.loadBackupCredential(key)
        if cred == nil {
            return cred
        }
        if (self.isExpired(cred!)) {
            try _storage.clearBackupCredential(key)
        }
        return cred
    }
    
    private func isExpired(_ credentialStr: String) -> Bool {
        do {
            let c = try VerifiableCredential.fromJson(credentialStr)
            // TODO: c.getExpirationDate() == nil
            let currentTime = Date()

            return try currentTime > c.getExpirationDate()!
        } catch {
            return true
        }
    }


    private func saveToken(_ jwtCode: String) throws {
        let key = self.getStorageKey()
        try _storage.storeBackupCredential(key, jwtCode)

    }

}
