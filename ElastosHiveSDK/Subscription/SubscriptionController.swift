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

/// The subscription controller is for subscribing the vault or the backup.
public class SubscriptionController {
    private var _connectionManager: ConnectionManager
    
    public init(_ serviceEndpoint: ServiceEndpoint) {
        _connectionManager = serviceEndpoint.connectionManager!
    }
     
    /// Get the pricing plan list of the vault which can be used for upgrading the vault.
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: The price plan list.
    public func getVaultPricingPlanList() throws -> [PricingPlan] {
        return try _connectionManager.getPricePlans("vault", "").execute(PricingPlanCollection.self).pricingPlans!
    }
    
    /// Get the pricing plan for the vault by name.
    /// - Parameter planName: The name of the pricing plan.
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: The pricing plan
    public func getVaultPricingPlan(_ planName: String?) throws -> PricingPlan {
        return try _connectionManager.getPricePlans("vault", planName!).execute(PricingPlanCollection.self).pricingPlans!.first!
    }
    
    /// Get the details of the vault.
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: The details of the vault.
    public func getVaultInfo() throws -> VaultInfo {
        return try _connectionManager.getVaultInfo().execute(VaultInfo.self)
    }
    
    public func getAppStats() throws -> [AppInfo]? {
        return try _connectionManager.getVaultAppStats().execute(AppStats.self).apps
    }

    /// Subscribe the vault with the free pricing plan.
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: The details of the new created vault.
    public func subscribeToVault() throws -> VaultInfo {
        return try _connectionManager.subscribeToVault().execute(VaultInfo.self)
    }
    
    /// Unsubscribe the vault.
    /// - Throws: HiveError The error comes from the hive node.
    public func unsubscribeVault(_ force: Bool) throws {
        try _ = _connectionManager.unsubscribeVault(force).execute()
    }
    
    /// Activate vault
    /// @throws HiveException The error comes from the hive node.
    public func activateVault() throws {
        do {
            try _connectionManager.activateVault().execute();
        } catch {
            // TODO: error
            throw error
        }
    }

    /// Deactivate vault
    /// @throws HiveException The error comes from the hive node.
    public func deactivateVault() throws {
        do {
            try _connectionManager.deactivateVault().execute();
        } catch {
            // TODO: error
            throw error
        }
    }


    
    /// Get the pricing plan list of the backup service which can be used for upgrading the service.
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: The price plan list.
    public func getBackupPricingPlanList() throws -> [PricingPlan] {
        return try _connectionManager.getPricePlans("backup", "").execute(PricingPlanCollection.self).backupPlans!
    }

    /// Get the pricing plan for the backup by name.
    /// - Parameter planName: The name of the pricing plan.
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: The pricing plan
    public func getBackupPricingPlan(_ planName: String?) throws -> PricingPlan {
        return try _connectionManager.getPricePlans("backup", planName!).execute(PricingPlanCollection.self).backupPlans!.first!
    }

    /// Get the details of the backup service.
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: The details of the backup service.
    public func getBackupInfo() throws -> BackupInfo {
        return try _connectionManager.getBackupInfo().execute(BackupInfo.self)
    }

    /// Subscribe the backup service with the free pricing plan.
    /// - Throws: HiveError The error comes from the hive node.
    /// - Returns: The details of the new created backup service.
    public func subscribeToBackup(_ reserved: String?) throws -> BackupInfo {
        return try _connectionManager.subscribeToBackup(reserved).execute(BackupInfo.self)
    }

    /// Unsubscribe the backup service.
    /// - Throws: HiveError The error comes from the hive node.
    public func unsubscribeBackup() throws {
        try _ = _connectionManager.unsubscribeBackup().execute()
    }
}

