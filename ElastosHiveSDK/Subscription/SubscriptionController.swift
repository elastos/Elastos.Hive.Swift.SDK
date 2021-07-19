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

public class SubscriptionController {
    private var _connectionManager: ConnectionManager
    
    public init(_ serviceEndpoint: ServiceEndpoint) {
        _connectionManager = serviceEndpoint.connectionManager!
    }
     
    public func getVaultPricingPlanList() throws -> [PricingPlan] {
        return try _connectionManager.getPricePlans("vault", "").execute(PricingPlanCollection.self).pricingPlans!
    }
    
    public func getVaultPricingPlan(_ planName: String?) throws -> PricingPlan {
        return try _connectionManager.getPricePlans("vault", planName!).execute(PricingPlanCollection.self).pricingPlans!.first!
    }
    
    public func getVaultInfo() throws -> VaultInfo {
        return try _connectionManager.getVaultInfo().execute(VaultInfo.self)
    }

    public func subscribeToVault(_ credential: String?) throws -> VaultInfo {
        if credential == nil {
            throw HiveError.NotImplementedException(nil)
        }
        return try _connectionManager.subscribeToVault(credential!).execute(VaultInfo.self)
    }
    
    public func unsubscribeVault() throws {
        try _ = _connectionManager.unsubscribeVault().execute()
    }
    
    public func getBackupPricingPlanList() throws -> [PricingPlan] {
        return try _connectionManager.getPricePlans("backup", "").execute(PricingPlanCollection.self).backupPlans!
    }

    public func getBackupPricingPlan(_ planName: String?) throws -> PricingPlan {
        return try _connectionManager.getPricePlans("backup", planName!).execute(PricingPlanCollection.self).backupPlans!.first!
    }

    public func getBackupInfo() throws -> BackupInfo {
        return try _connectionManager.getBackupInfo().execute(BackupInfo.self)
    }

    public func subscribeToBackup(_ reserved: String?) throws -> BackupInfo {
        return try _connectionManager.subscribeToBackup(reserved).execute(BackupInfo.self)
    }

    public func unsubscribeBackup() throws {
        try _ = _connectionManager.unsubscribeVault().execute()
    }
}

