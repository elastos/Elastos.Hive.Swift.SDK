/*
* Copyright (c) 2021 Elastos Foundation
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
import ObjectMapper

public class BackupInfo: Mappable {
    public var did: String?
    public var maxStorage: Int64?
    public var fileUseStorage: Int64?
    public var dbUseStorage: Int64?
    public var modifyTime: Date?
    public var startTime: Date?
    public var endTime: Date?
    public var pricingUsing: String?
    public var isExisting: Bool?

    public init() {
    
    }
    
    public required init?(map: Map) {}
    
    public func mapping(map: Map) {}
}

public class BackupSubscription: ServiceEndpoint, SubscriptionProtocol, PaymentProtocol {
    private var _paymentService: PaymentServiceRender?
    private var _subscriptionService: SubscriptionServiceRender?
    
    public override init(_ context: AppContext, _ providerAddress: String) throws {
        try super.init(context, providerAddress)
        self._paymentService = PaymentServiceRender(self)
        self._subscriptionService = SubscriptionServiceRender(self)
    }

    public func subscribe() -> Promise<BackupInfo> {
        return Promise<Any>.async().then { _ -> Promise<BackupInfo> in
            return Promise<BackupInfo> { resolver in
                self._subscriptionService!.subscribeBackup().then { _ -> Promise<VaultInfoResponse> in
                    return self._subscriptionService!.getBackupVaultInfo()
                }.done { response in
                    let backupInfo = self.getBackupInfoByResponseBody(response)
                    resolver.fulfill(backupInfo)
                }.catch { error in
                    resolver.reject(error)
                }
            }
        }
    }
    
    public func unsubscribe() -> Promise<Void> {
        return Promise<Void> { resolver in
            resolver.reject(HiveError.UnsupportedMethodException)
        }
    }

    public func activate() -> Promise<Void> {
        return Promise<Void> { resolver in
            resolver.reject(HiveError.UnsupportedMethodException)
        }
    }
    
    public func deactivate() -> Promise<Void> {
        return Promise<Void> { resolver in
            resolver.reject(HiveError.UnsupportedMethodException)
        }
    }
    
    public func checkSubscription() -> Promise<BackupInfo> {
        return Promise<Any>.async().then { _ -> Promise<BackupInfo> in
            return Promise<BackupInfo> { resolver in
                self._subscriptionService!.getBackupVaultInfo().done({ response in
                    let backupInfo = self.getBackupInfoByResponseBody(response)
                    resolver.fulfill(backupInfo)
                }).catch { error in
                    resolver.reject(error)
                }
            }
        }
    }
    
    public func getPricingPlanList() -> Promise<Array<PricingPlan>?> {
        return Promise<Void>.async().then { [self] _ -> Promise<Array<PricingPlan>?> in
            return self._paymentService!.getPricingPlanList()
        }
    }

    public func getPricingPlan(_ planName: String) -> Promise<PricingPlan?> {
        return Promise<Void>.async().then { [self] _ -> Promise<PricingPlan?> in
            return self._paymentService!.getPricingPlan(planName)
        }
    }
    
    public func placeOrder(_ planName: String) -> Promise<Order?> {
        return Promise<Void>.async().then { [self] _ -> Promise<Order?> in
            return Promise<Order?> { resolver in
                self._paymentService!.createPricingOrder(planName).then({ orderId -> Promise<Order?> in
                    return self._paymentService!.getOrderInfo(orderId!)
                }).done { order in
                    resolver.fulfill(order)
                }.catch { error in
                    resolver.reject(error)
                }
            }
        }
    }
    
    public func getOrder(_ orderId: String) -> Promise<Order?> {
        return Promise<Void>.async().then { [self] _ -> Promise<Order?> in
            return self._paymentService!.getOrderInfo(orderId)
        }
    }
    
    public func payOrder(_ orderId: String, _ transIds: [String]) -> Promise<Receipt?> {
        return Promise<Void>.async().then { [self] _ -> Promise<Receipt?> in
            return self._paymentService!.payOrder(orderId, transIds)
        }
    }
    
    public func getReceipt(_ receiptId: String) -> Promise<Receipt?> {
        return Promise<Receipt?> { resolver in
            resolver.reject(HiveError.UnsupportedMethodException)
        }
    }
    
    private func getBackupInfoByResponseBody(_ response: VaultInfoResponse) -> BackupInfo {
        let backupInfo = BackupInfo()
        backupInfo.did = response.did
        backupInfo.maxStorage = response.maxStorage
        backupInfo.fileUseStorage = response.fileUseStorage
        backupInfo.dbUseStorage = response.dbUseStorage
        backupInfo.modifyTime = Date(timeIntervalSince1970: TimeInterval(integerLiteral: response.modifyTime))
        backupInfo.startTime = Date(timeIntervalSince1970: TimeInterval(integerLiteral: response.startTime))
        backupInfo.endTime = Date(timeIntervalSince1970: TimeInterval(integerLiteral: response.endTime))
        backupInfo.pricingUsing = response.pricingUsing
        backupInfo.isExisting = response.isExisting
        return backupInfo
    }
}

