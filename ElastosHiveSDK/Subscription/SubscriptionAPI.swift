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

extension HiveAPi {
    func getPricePlans() -> String {
        return self.baseURL + self.apiPath + "/subscription/pricing_plan"
    }
    
    // for subscription to vault service.
    func subscribeToVault() -> String {
        return self.baseURL + self.apiPath + "/subscription/vault"
    }
    
    func activateVault() -> String {
        return self.baseURL + self.apiPath + "/subscription/vault?op=activation"
    }
    
    func deactivateVault() -> String {
        return self.baseURL + self.apiPath + "/subscription/vault?op=deactivation"
    }
    
    func unsubscribeVault() -> String {
        return self.baseURL + self.apiPath + "/subscription/vault"
    }
    
    func getVaultInfo() -> String {
        return self.baseURL + self.apiPath + "/subscription/vault"
    }
    
    // for subscription to backup service.
    func subscribeToBackup() -> String {
        return self.baseURL + self.apiPath + "/subscription/backup"
    }
    
    func activateBackup() -> String {
        return self.baseURL + self.apiPath + "/subscription/backup?op=activation"
    }
    
    func deactivateBackup() -> String {
        return self.baseURL + self.apiPath + "/subscription/backup?op=deactivation"
    }
    
    func unsubscribeBackup() -> String {
        return self.baseURL + self.apiPath + "/subscription/backup"
    }
    
    func getBackupInfo() -> String {
        return self.baseURL + self.apiPath + "/subscription/backup"
    }
}
