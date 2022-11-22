/*
* Copyright (c) 2020 Elastos Foundation
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

/// The service builder for the services of the backup hive node.
/// Helper class to create service instance.
public class ServiceBuilder {
    private var _serviceEndpoint: ServiceEndpoint
    
    /// Create by the service end point.
    /// - Parameter serviceEndpoint: The service end point.
    public init(_ serviceEndpoint: ServiceEndpoint) {
        _serviceEndpoint = serviceEndpoint
    }

    /// Create the service for the files module.
    /// - Returns: The instance of file service.
    public func createFilesService() -> FilesService {
        return FilesServiceRender(_serviceEndpoint)
    }
    
    /// Create the service for the database module.
    /// - Returns: The instance of database service.
    public func createDatabase() -> DatabaseService {
        return DatabaseServiceRender(_serviceEndpoint);
    }
    
    /// Create the service for the database module.
    /// - Returns: The instance of database service.
    public func createEncryptionDatabase(_ cipher: DIDCipher, _ nonce: String) -> DatabaseService {
        return EncryptionDatabaseRender(_serviceEndpoint, cipher,  Array(nonce.utf8))
    }
    
    /// Create the service of the scripting module.
    /// - Returns: The instance of scripting service.
    public func createScriptingService() -> ScriptingService{
        return ScriptingServiceRender(_serviceEndpoint)
    }

    /// Create the service of the backup module.
    /// - Returns: The instance of the backup service.
    public func createBackupService() -> BackupService {
        return BackupServiceRender(_serviceEndpoint)
    }
    
    /// Create the service of the promotion module.
    /// - Returns: The instance of the promotion service.
    public func createPromotionService() -> PromotionService {
        return PromotionServiceRender(_serviceEndpoint)
    }
}
