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

public class HiveChildren: Result {
    public var children: Array<HiveItemInfo>

    public override init() {
        children = []
    }

    func installValue(_ jsonData: JSON, _ type: DriveType) {
        let childrenData = jsonData.arrayValue
        switch type {
        case .nativeStorage: break
        case .oneDrive:
            for it in childrenData {
                let folder = JSON(it["folder"])
                var type = "folder"
                if folder["childCount"].stringValue == "" {
                    type = "file"
                }
                let dic = [HiveItemInfo.itemId: it["id"].stringValue,
                           HiveItemInfo.name: it["name"].stringValue,
                           HiveItemInfo.size: String(it["size"].int64Value),
                           HiveItemInfo.type: type]
                let item = HiveItemInfo(dic)
                children.append(item)
            }
        case .hiveIPFS:
            for it in childrenData {
                let folder = it["Type"].stringValue
                var type = "folder"
                if folder == "1" {
                    type = "file"
                }
                let dic = [HiveItemInfo.itemId: it["Id"].stringValue,
                           HiveItemInfo.name: it["Name"].stringValue,
                           HiveItemInfo.size: String(it["Size"].int64Value),
                           HiveItemInfo.type: type]
                let item = HiveItemInfo(dic)
                children.append(item)
            }
        case .dropBox: break
        case .ownCloud:break
        }
    }
}
