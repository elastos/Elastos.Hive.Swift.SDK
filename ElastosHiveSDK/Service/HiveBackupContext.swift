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
 * The backup context for hive node server.
 */
public class HiveBackupContext: BackupContext {
    public func getParameter(_ parameter: String) -> String? {
        switch parameter {
        case "targetAddress":
            return getTargetProviderAddress()
        case "targetServiceDid":
            return getTargetServiceDid()
        default:
            return nil
        }
    }
    
    /// Get the backup destination type which the vault want to go.
    public func getType() -> String? {
        return nil
    }
    
    /// Get the authorization information for the backup processing. The authorization information is for the hive node
    /// to access the backup server which the backup information is in.
    /// - Parameters:
    ///   - srcDid: hive node service instance DID.
    ///   - targetDid: The instance did of the destination of the backup.
    ///   - targetHost: The host url of the destination of the backup.
    public func getAuthorization(_ srcDid: String?, _ targetDid: String?, _ targetHost: String?) -> Promise<String>? {
        return nil
    }
    
    /// Get the host URL of the backup server.
    /// - returns: Host URL.
    public func getTargetProviderAddress() -> String? {
        return nil
    }
    
    /// Get the service DID of the backup server.
    /// - returns: The service DID.
    public func getTargetServiceDid() -> String? {
        return nil
    }
}
