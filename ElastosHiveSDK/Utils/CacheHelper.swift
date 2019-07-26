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

@inline(__always) private func TAG() -> String { return "KeyChainHelper" }

class CacheHelper: NSObject {

    class func checkCacheFileIsExist(_ cacheFilePath: String, _ path: String) -> Bool {
        let cachePath: String = "\(cacheFilePath)/\(path)"
        let fileManager = FileManager.default
        let isExist: Bool = fileManager.fileExists(atPath: cachePath)
        return isExist
    }

    class func saveCache(_ cacheFilePath: String, _ path: String, data: Data) -> Bool {
        let cachePath: String = "\(cacheFilePath)/\(path)"
        let fileManager = FileManager.default
        let exist: Bool = fileManager.fileExists(atPath: cacheFilePath)
        if (!exist) {
            do {
                try fileManager.createDirectory(atPath: cacheFilePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch{
                Log.e(TAG(), "create \(cachePath) error: \(error.localizedDescription)")
                return false
            }
        }
        let existFile: Bool = fileManager.fileExists(atPath: cachePath)
        if !existFile {
            let isSuccess: Bool = fileManager.createFile(atPath: cachePath, contents: nil, attributes: nil)
            guard isSuccess else {
                Log.e(TAG(), "create \(cachePath) failed")
                return false
            }
        }
        do{
            try data.write(to: URL(fileURLWithPath: cachePath))
        }
        catch{
            Log.e(TAG(), "write data with \(cachePath) failed")
            return false
        }
        return true
    }

    class func writeCache(_ cacheFilePath: String, _ path: String, data: Data, _ position: UInt64, _ appendEnd: Bool) -> Int32 {
        let cachePath: String = "\(cacheFilePath)/\(path)"
        let fileManager = FileManager.default
        let cacheExist: Bool = fileManager.fileExists(atPath: cacheFilePath)
        if (!cacheExist) {
            do {
                try fileManager.createDirectory(atPath: cacheFilePath, withIntermediateDirectories: true, attributes: nil)
            }
            catch{
                Log.e(TAG(), "create \(cachePath) error: \(error.localizedDescription)")
                return -1
            }
        }

        let existFile: Bool = fileManager.fileExists(atPath: cachePath)
        if !existFile {
            let isSuccess = fileManager.createFile(atPath: cachePath, contents: nil, attributes: nil)
            guard isSuccess else {
                Log.e(TAG(), "create \(cachePath) failed")
                return -1
            }
        }

        let writeHandle: FileHandle = FileHandle(forWritingAtPath: cachePath)!
        writeHandle.seek(toFileOffset: position)
        if appendEnd {
            writeHandle.seekToEndOfFile()
        }
        writeHandle.write(data)
        return Int32(data.count)
    }

    class func readCache(_ cacheFilePath: String, _ path: String, _ position: UInt64, _ length: Int) -> Data {
        let cachePath: String = "\(cacheFilePath)/\(path)"
        let fileManager = FileManager.default
        let exist: Bool = fileManager.fileExists(atPath: cachePath)
        if (exist) {
            do {
                let readHandler = FileHandle(forReadingAtPath: cachePath)!
                let attributes = try fileManager.attributesOfItem(atPath: cachePath)
                let fileSize = attributes[FileAttributeKey.size] as! UInt64
                var dt = Data()
                if position > fileSize {
                    Log.d(TAG(), "read finished")
                    return Data()
                }
                readHandler.seek(toFileOffset: position)
                if fileSize <= length {
                    dt = readHandler.readDataToEndOfFile()
                }
                else {
                    if fileSize >= position + UInt64(length)
                    {
                        dt = (readHandler.readData(ofLength: length))
                    }
                    else{
                        dt = (readHandler.readDataToEndOfFile())
                    }
                }
                return dt
            }
            catch {
                return Data()
            }
        }
        else { return Data() }
    }

    class func uploadFile(_ cacheFilePath: String, _ path: String) -> Data  {
        let copyPath: String = "\(cacheFilePath)/\(path)"
        let fileManager = FileManager.default
        let exist: Bool = fileManager.fileExists(atPath: copyPath)
        if (exist) {
            let readHandler = FileHandle(forReadingAtPath: copyPath)!
            var dt: Data = Data()
            readHandler.seek(toFileOffset: 0)
            dt = (readHandler.readDataToEndOfFile())
            return dt
        }
        else { return Data() }
    }

    class func clearCache(_ cacheFilePath: String, _ path: String) {
        let cachePath: String = "\(cacheFilePath)/\(path)"
        let fileManager = FileManager.default
        let exist: Bool = fileManager.fileExists(atPath: cachePath)
        if exist {
            do {
                try fileManager.removeItem(atPath: cachePath)
            }
            catch {}
        }
    }
}
