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

class VaultAuthInfoStoreImpl: Persistent {
    private var storePath: String
    private var realyPath: String
    private var ownerDid: String
    private var provider: String
    private var fileName: String
    init(_ ownerDid: String, _ provider: String, _ storePath: String) {
        self.storePath = storePath
        self.ownerDid = ownerDid
        self.provider = provider
        let tokenPath = storePath + "token/"
        fileName = (ownerDid + provider).md5
        self.realyPath = tokenPath + fileName
    }

    func parseFrom() -> Dictionary<String, Any> {
        let fileManager = FileManager.default
        let exist: Bool = fileManager.fileExists(atPath: realyPath)
        if (exist) {
            do {
                let readHandler = FileHandle(forReadingAtPath: realyPath)!
                let data = readHandler.readDataToEndOfFile()
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any] ?? [: ]
                return json
            }
            catch {
                print(error)
            }
        }
        return [: ]
    }

    func upateContent(_ json: Dictionary<String, Any>) {
        let fileManager = FileManager.default
        let exist: Bool = fileManager.fileExists(atPath: realyPath)
        do {
            if !exist {
                let perpath = realyPath.prefix(realyPath.count - fileName.count)
                try fileManager.createDirectory(atPath: String(perpath), withIntermediateDirectories: true, attributes: nil)
                fileManager.createFile(atPath: realyPath, contents: nil, attributes: nil)
            }
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            try data.write(to: URL(fileURLWithPath: realyPath))
        } catch {
            print(error)
        }
    }
}
