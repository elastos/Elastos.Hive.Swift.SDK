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

public class BackupServiceRender: BackupService {
    private var _serviceEndpoint: ServiceEndpoint
    private var _controller: BackupController
    private var _credentialCode: CredentialCode?
    
    public init(_ serviceEndpoint: ServiceEndpoint) {
        _serviceEndpoint = serviceEndpoint
        _controller = BackupController(serviceEndpoint)
    }
    
    /// Set-up a context for get more detailed information for backup server.
    /// - Parameter backupContext: context for providing backup server details.
    /// - Returns: Void
    public func setupContext(_ backupContext: BackupContext) -> Promise<Void> {
        _credentialCode = CredentialCode(_serviceEndpoint, backupContext)
        return DispatchQueue.global().async(.promise){ [self] in
            return Void()
        }
    }
    
    /// Backup process in node side is a continues process. Vault node server backup whole vault data to
    /// backup server and keep syncing with it. This is for user personal data security.
    ///
    /// <p>This function is for starting a background scheduler to update data to backup server. It's an
    /// async process.</p>
    /// - Returns: Void
    public func startBackup() -> Promise<Void> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller.startBackup(try _credentialCode!.getToken()!)
        }
    }
    
    /// As startBackup() shows, this is just for stopping the async process in vault node side.
    /// - Returns: Void
    public func stopBackup() -> Promise<Void> {
        return DispatchQueue.global().async(.promise){ [self] in
            return Void()
        }
    }

    /// This is for restore vault data from backup server only once.
    /// The action is processed async in node side.
    /// - Returns: Void
    public func restoreFrom() -> Promise<Void> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller.restoreFrom(try _credentialCode!.getToken()!)
        }
    }

    /// Stop the running restore process in background.
    /// - Returns: Void
    public func stopRestore() -> Promise<Void> {
        return DispatchQueue.global().async(.promise){ [self] in
            return Void()
        }
    }

    /// Check the current status of the node side backup process.
    /// - Returns: Void
    public func checkResult() throws -> Promise<BackupResultState> {
        return DispatchQueue.global().async(.promise){ [self] in
            return try _controller.checkResult()
        }
    }
}
