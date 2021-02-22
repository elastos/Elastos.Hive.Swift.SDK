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

class BackupPersistentImpl: Persistent {
    private var storePath: String
    private var configPath: String
    private var fileName: String
    private var targetHost: String
    private var targetDID: String
    private var type: String
    
    init(_ targetHost: String, _ targetDID: String, _ type: String, _ storePath: String) {
        self.targetHost = targetHost
        self.targetDID = targetDID
        self.type = type
        self.storePath = storePath
        let tokenPath = storePath + "backup/"
        fileName = (targetHost + targetDID + type).md5
        self.configPath = tokenPath + fileName
    }
    
    func parseFrom() throws -> Dictionary<String, Any> {
        let fileManager = FileManager.default
        let exist: Bool = fileManager.fileExists(atPath: configPath)
        if (exist) {
            let readHandler = FileHandle(forReadingAtPath: configPath)!
            let data = readHandler.readDataToEndOfFile()
            let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any] ?? [: ]
            return json
        }
        return [: ]
    }

    func upateContent(_ json: Dictionary<String, Any>) throws {
        let fileManager = FileManager.default
        let exist: Bool = fileManager.fileExists(atPath: configPath)
        if !exist {
            let perpath = configPath.prefix(configPath.count - fileName.count)
            try fileManager.createDirectory(atPath: String(perpath), withIntermediateDirectories: true, attributes: nil)
            fileManager.createFile(atPath: configPath, contents: nil, attributes: nil)
        }
        let checker = JSONSerialization.isValidJSONObject(json)
        guard checker else {
            throw HiveError.jsonSerializationInvalidType(des: "HiveSDK serializate: JSONSerialization Invalid type in JSON.")
        }
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        try data.write(to: URL(fileURLWithPath: configPath))
    }
    
    func deleteContent() throws {
        let tokenPath = storePath + "token/"
        let fileName = (targetHost + targetDID + type).md5
        let fileManager = FileManager.default
        let rePath = tokenPath + fileName
        let exist: Bool = fileManager.fileExists(atPath: rePath)
        if exist {
            print(rePath)
            try fileManager.removeItem(atPath: rePath)
        }
    }
}

