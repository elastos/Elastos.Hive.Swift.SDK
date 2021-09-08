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

/// Backup context to provide backup information when doing backup relating things for the vault.
public protocol BackupContext {
    
    /// Get the backup destination type which the vault want to go.
    func getType() -> String?
    
    /// Get the parameter for backup operation by key.
    /// - Parameter key: The parameter name.
    func getParameter(_ key: String) -> String?
    
    /// Get the authorization information for the backup processing. The authorization information is for the hive node
    /// to access the backup server which the backup information is in.
    /// - Parameters:
    ///   - srcDid: hive node service instance DID.
    ///   - targetDid: The instance did of the destination of the backup.
    ///   - targetHost: The host url of the destination of the backup.
    func getAuthorization(_ srcDid: String?, _ targetDid: String?, _ targetHost: String?) -> Promise<String>?
}
