//
//  HiveDirectoryInfo.swift
//  ElastosHiveSDK
//
//  Created by 李爱红 on 2019/5/16.
//  Copyright © 2019 org.elastos. All rights reserved.
//

import UIKit

class HiveDirectoryInfo: NSObject {

    public var dirId: String?

    init(_ dirId: String) {
        self.dirId = dirId
        super.init()
    }

}
