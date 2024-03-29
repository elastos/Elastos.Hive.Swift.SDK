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

/// Cloud backup context is used for the user to backup the vault data to the cloud service,
/// such as google driver, etc.
public class CloudBackupContext: BackupContext {
    public func getParameter(_ key: String) -> String? {
        switch key {
        case "clientId":
            return getClientId()
        case "redirectUrl":
            return getRedirectUrl()
        case "scope":
            return getAppScope()
        default:
            return nil
        }
    }
    
    public func getType() -> String? {
        return nil
    }
    
    public func getAuthorization(_ srcDid: String?, _ targetDid: String?, _ targetHost: String?) -> Promise<String>? {
        return nil
    }
    
    /// Get the client ID for access the cloud service.
    public func getClientId() -> String? {
        return nil
    }
    
    /// Get the redirect URL.
    public func getRedirectUrl() -> String? {
        return nil
    }
    
    /// Get the application scope.
    public func getAppScope() -> String? {
        return nil
    }
}
