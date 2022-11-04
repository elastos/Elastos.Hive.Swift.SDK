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

extension ConnectionManager {
    func getPricePlans(_ subscription: String, _ name: String) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/subscription/pricing_plan?subscription=\(subscription)&name=\(name)"
        return try self.createDataRequest(url, .get, nil)
    }
    
    func subscribeToVault() throws -> DataRequest {
        let url = self.baseURL + "/api/v2/subscription/vault"
        return try self.createDataRequest(url, .put, nil)
    }

    func activateVault() throws -> DataRequest {
        let url = self.baseURL + "/api/v2/subscription/vault?op=activation"
        return try self.createDataRequest(url, .post, nil)
    }
    
    func deactivateVault() throws -> DataRequest {
        let url = self.baseURL + "/subscription/vault?op=deactivation"
        return try self.createDataRequest(url, .post, nil)
    }
    
    func unsubscribeVault(_ force: Bool) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/subscription/vault?force=\(force)"
        return try self.createDataRequest(url, .delete, nil)
    }

    func getVaultInfo() throws -> DataRequest {
        let url = self.baseURL + "/api/v2/subscription/vault"
        return try self.createDataRequest(url, .get, nil)
    }
    
    func getVaultAppStats() throws -> DataRequest {
        let url = self.baseURL + "/api/v2/subscription/vault/app_stats"
        return try self.createDataRequest(url, .get, nil)
    }
    
    // for subscription to backup service.
    func subscribeToBackup(_ credential: String?) throws -> DataRequest {
        let url = self.baseURL + "/api/v2/subscription/backup?credential=\(credential ?? "")"
        return try self.createDataRequest(url, .put, nil)
    }
    
    func activateBackup() throws -> DataRequest {
        let url = self.baseURL + "/api/v2/subscription/backup?op=activation"
        return try self.createDataRequest(url, .post, nil)
    }
    
    func deactivateBackup() throws -> DataRequest {
        let url = self.baseURL + "/api/v2/subscription/backup?op=deactivation"
        return try self.createDataRequest(url, .post, nil)
    }
    
    func unsubscribeBackup() throws -> DataRequest {
        let url = self.baseURL + "/api/v2/subscription/backup"
        return try self.createDataRequest(url, .delete, nil)
    }
    
    func getBackupInfo() throws -> DataRequest {
        let url = self.baseURL + "/api/v2/subscription/backup"
        return try self.createDataRequest(url, .get, nil)
    }
}
