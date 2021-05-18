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

/**
 * Hive node provides the subscription service to let a new user subscribe to their
 * vault or backup service on the given back-end node.
 */
public protocol SubscriptionProtocol {
    associatedtype T

   
    /// Let a new user subscribe to the entity service on the specified back-end
    /// node, where the entity service would be vault or backup service.
    /// Currently this method would only support for subscription to a entity service
    /// with free pricing plan. When there is already a corresponding service existed,
    /// no new service would be subscribed or created.
    ///
    /// - parameter credential: The credential used to subscribe to a vault or backup service,
    /// currently this parameter would be reserved for future usage.
    /// - returns: The basic information of the newly created or existing vault on success,
    /// otherwise, the specific exception would returned in the wrapper.
    func subscribe(_ credential: String) -> Promise<T?>

    /// Let user to unsubscribe to an existing but useless vault or backup service.
    ///
    /// - Returns: None would be returned on success, otherwise, the specific exception would be returned.
    func unsubscribe() -> Promise<Void>
    
    
    /// Let user to activate the vault to start the service for data storage.
    /// Currently this method only would be reserved for future usage.
    ///
    /// - Returns: None would be returned on success, otherwise, the specific exception would be returned.
    func activate() -> Promise<Void>
    
    /// Deactivate the vault to stop the service for data storage. Currently this method only would be reserved for
    /// future usage.
    ///
    /// - Returns: None would be returned on success, otherwise, the specific exception would be returned.
    func deactivate() -> Promise<Void>

    /// Let the user to get the basic information of the subscription.
    ///
    /// - Returns: The basic information of the newly created or existing vault on success, otherwise, the specific
    /// exception would returned in the wrapper.
    func checkSubscription() -> Promise<T>
}
