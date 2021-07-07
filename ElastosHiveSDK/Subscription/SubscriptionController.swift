///*
// * Copyright (c) 2019 Elastos Foundation
// *
// * Permission is hereby granted, free of charge, to any person obtaining a copy
// * of this software and associated documentation files (the "Software"), to deal
// * in the Software without restriction, including without limitation the rights
// * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// * copies of the Software, and to permit persons to whom the Software is
// * furnished to do so, subject to the following conditions:
// *
// * The above copyright notice and this permission notice shall be included in all
// * copies or substantial portions of the Software.
// *
// * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// * SOFTWARE.
// */
//
//import Foundation
//
//public class SubscriptionController {
//    private var _connectionManager: ConnectionManager
//    
//    public init(_ connectionManager: ConnectionManager) {
//        _connectionManager = connectionManager
//    }
//    
////    public func getVaultPricingPlanList() throws -> [PricingPlan]? {
////        // TODO
////        return _connectionManager.getPricePlans("vault", "").execute([PricingPlan])
////    }
//    
//    public func getVaultPricingPlan(_ planName: String?) throws -> PricingPlan? {
//        // TODO
//        return nil
//    }
//    
//    public func getVaultInfo(_ planName: String?) throws -> VaultInfo? {
//        // TODO
//        return nil
//    }
//
//    public func subscribeToVault(_ credential: String?) -> VaultInfo? {
//        // TODO
//        return nil
//    }
//    
//    public func unsubscribeVault() throws {
//        // TODO
//    }
//    
//    public func getBackupPricingPlanList() throws -> [PricingPlan]? {
//        // TODO
//        return nil
//    }
//
//    public func getBackupPricingPlan(_ planName: String?) throws -> PricingPlan? {
//        
//        return nil
//        
////        try {
////                    return subscriptionAPI.getPricePlans("backup", "")
////                                        .execute()
////                                        .body()
////                                        .getBackupPlans();
////                } catch (NodeRPCException e) {
////                    switch (e.getCode()) {
////                    case NodeRPCException.UNAUTHORIZED:
////                        throw new UnauthorizedException(e);
////                    default:
////                        throw new ServerUnkownException(e);
////                    }
////                } catch (IOException e) {
////                    throw new NetworkException(e);
////                }
//    }
//
//    public func getBackupInfo() throws -> BackupInfo? {
//        do {
//            return try _connectionManager.getBackupInfo().execute(BackupInfo.self)
//        } catch  {
//            throw error
//        }
//    }
//
//    public func subscribeToBackup(_ reserved: String) throws -> BackupInfo? {
//        do {
//            return try _connectionManager.subscribeToBackup(reserved).execute(BackupInfo.self)
//        } catch  {
//            throw error
//        }
//    }
//
//    public func unsubscribeBackup(_ reserved: String?) throws {
//        do {
//            try _ = _connectionManager.unsubscribeVault().execute()
//        } catch  {
//            throw error
//        }
//    }
//}
//
