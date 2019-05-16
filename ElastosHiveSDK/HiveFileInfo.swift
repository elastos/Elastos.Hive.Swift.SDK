//
//  HiveFileInfo.swift
//  ElastosHiveSDK
//
//  Created by 李爱红 on 2019/5/16.
//  Copyright © 2019 org.elastos. All rights reserved.
//

import UIKit

class HiveFileInfo: NSObject {

    private var fileId: String?

    init(_ fileId: String) {
        self.fileId = fileId
        super.init()
    }
    
}
