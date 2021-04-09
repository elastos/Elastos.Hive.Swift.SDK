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

/**
 * Backup service is for doing backup vault data from vault node server to backup server.
 * Backup server maybe another node server or third-party centered server like Google Driver.
 * As a restrict, only one vault can be used for one DID.
 * User also need just one backup copy for vault data.
 */
public enum BackupResult {
    case stop
    case backup
    case restore
    case unknown
}

public protocol BackupProtocol {
    
    /// Set-up a context for get more detailed information for backup server.
    ///
    /// - Parameter context context for providing backup server details.
    /// - Returns: Void
    func setupContext(_ context: BackupContext) throws -> Promise<Void>
    
    /// Backup process in node side is a continues process. Vault node server backup whole vault data to backup server and keep syncing with it. This is for user personal data security. This function is for starting a background scheduler to update data to backup server. It's an async process.
    ///
    /// - Returns: Void
    func startBackup() -> Promise<Void>

    /// As startBackup() shows, this is just for stopping the async process in vault node side.
    ///
    /// - Returns: Void
    func stopBackup() -> Promise<Void>

    /// This is for restore vault data from backup server only once. The action is processed async in node side.
    ///
    /// - Returns: Void
    func restoreFrom() -> Promise<Void>

    /// Stop the running restore process in background.
    ///
    /// - Returns: Void
    func stopRestore() -> Promise<Void>

    /// Stop the running restore process in background.
    ///
    /// - Returns: Void
    func checkResult() -> Promise<BackupResult>
}
