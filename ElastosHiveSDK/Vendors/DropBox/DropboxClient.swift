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
import PromiseKit

@objc(DropboxClient)
internal class DropboxClient: HiveClientHandle {
    private static var clientInstance: HiveClientHandle?

    private init(_ param: DriveParameter) {
        super.init(DriveType.dropBox)
    }

    @objc(createInstance:)
    public static func createInstance(param: DriveParameter){
        if clientInstance == nil {
            let client: DropboxClient = DropboxClient(param)
            clientInstance = client as HiveClientHandle
        }
    }

    static func sharedInstance() -> HiveClientHandle? {
        return clientInstance
    }

    override func lastUpdatedInfo() -> HivePromise<HiveClientInfo> {
        return lastUpdatedInfo(handleBy: HiveCallback<HiveClientInfo>())
    }

    override func lastUpdatedInfo(handleBy: HiveCallback<HiveClientInfo>) -> HivePromise<HiveClientInfo> {
        let error = HiveError.failue(des: "TODO")
        return HivePromise<HiveClientInfo>(error: error)
    }

    override func defaultDriveHandle() -> HivePromise<HiveDriveHandle> {
        return defaultDriveHandle(handleBy: HiveCallback<HiveDriveHandle>())
    }

    override func defaultDriveHandle(handleBy: HiveCallback<HiveDriveHandle>) -> HivePromise<HiveDriveHandle> {
        let error = HiveError.failue(des: "TODO")
        return HivePromise<HiveDriveHandle>(error: error)
    }
}
