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

public class BackupUsingPlan: Result {
    
    private let DID = "did"
    private let BACK_UP_USING = "backup_using"
    private let MAX_STORAGE = "max_storage"
    private let USE_STORAGE = "use_storage"
    private let MODIFY_TIME = "modify_time"
    private let START_TIME = "start_time"
    private let END_TIME = "end_time"
    
    public var did: String {
        return paramars[DID].stringValue
    }
    
    public var maxStorage: Int {
        return paramars[MAX_STORAGE].intValue
    }
    
    public var useStorage: Int {
        return paramars[USE_STORAGE].intValue
    }

    public var modifyTime: Float {
        return paramars[MODIFY_TIME].floatValue
    }
    
    public var startTime: Int {
        return paramars[START_TIME].intValue
    }
    
    public var endTime: Float {
        return paramars[END_TIME].floatValue
    }

    public class func deserialize(_ content: String) throws -> BackupUsingPlan {
        let data = content.data(using: String.Encoding.utf8)
        let paramars = try JSONSerialization
            .jsonObject(with: data!,
                        options: .mutableContainers) as? [String : Any] ?? [: ]
        return BackupUsingPlan(JSON(paramars))
    }
    
    class func deserialize(_ content: JSON) -> BackupUsingPlan {
        return BackupUsingPlan(content)
    }
}
