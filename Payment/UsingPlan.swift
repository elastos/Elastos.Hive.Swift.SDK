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

public class UsingPlan: Result {
    private let DID = "did"
    private let MAX_STORAGE = "max_storage"
    private let FILE_USE_STORAGE = "file_use_storage"
    private let DB_USE_STOREAGE = "db_use_storage"
    private let MODIFY_TIME = "modify_time"
    private let START_TIME = "start_time"
    private let END_TIME = "end_time"
    private let PRICING_USING = "pricing_using"
    
    public var did: String {
        return paramars[DID].stringValue
    }
    
    public var maxStorage: Int {
        return paramars[MAX_STORAGE].intValue
    }
    
    public var fileUseStorage: Int {
        return paramars[FILE_USE_STORAGE].intValue
    }
    
    public var dbUseStorage: Float {
        return paramars[DB_USE_STOREAGE].floatValue
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
    
    public var name: String {
        return paramars[PRICING_USING].stringValue
    }

    public class func deserialize(_ content: String) throws -> UsingPlan {
        let data = content.data(using: String.Encoding.utf8)
        let paramars = try JSONSerialization
            .jsonObject(with: data!,
                        options: .mutableContainers) as? [String : Any] ?? [: ]
        return UsingPlan(JSON(paramars))
    }
    
    class func deserialize(_ content: JSON) -> UsingPlan {
        return UsingPlan(content)
    }
}
