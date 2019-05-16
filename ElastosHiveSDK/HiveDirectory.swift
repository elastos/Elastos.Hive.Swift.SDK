//
//  HiveDirectory.swift
//  ElastosHiveSDK
//
//  Created by 李爱红 on 2019/5/16.
//  Copyright © 2019 org.elastos. All rights reserved.
//

import UIKit

public class HiveDirectoryHandle: NSObject {
    var hiveFile: HiveFileHandle?

    func createDirectory(atName: String) -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        return nil
    }

    func getDirectory(atName: String) -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        return nil
    }

    func createFile(atName: String) -> CallbackFuture<HiveResult<HiveFileHandle>>? {
        return nil
    }

    func fileHandle(atName: String) -> CallbackFuture<HiveResult<HiveFileHandle>>? {
        return nil
    }

    func moveTo(atPath: String) -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        return nil
    }

    func copyTo(atPath: String) -> CallbackFuture<HiveResult<HiveDirectoryHandle>>? {
        return nil
    }

    func deleteItem() -> CallbackFuture<Bool>? {
        return nil
    }
}
