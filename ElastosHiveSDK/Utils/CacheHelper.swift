

import UIKit

@inline(__always) private func TAG() -> String { return "KeyChainHelper" }

class CacheHelper: NSObject {

    class func checkCacheFileIsExist(_ account:DriveType, _ path: String) -> Bool {
        let cachePath = NSHomeDirectory() + "/Library/Caches/" + account.rawValue + "/" + path
        let fileManager: FileManager = FileManager.default
        let isExist = fileManager.fileExists(atPath: cachePath)
        return isExist
    }

    class func saveCache(_ account: DriveType, _ path: String, data: Data) -> Bool {
        let cachePath = NSHomeDirectory() + "/Library/Caches/" + account.rawValue + "/" + path
        let cacheDirectory = ConvertHelper.prePath(cachePath)
        let fileManager: FileManager = FileManager.default
        let exist = fileManager.fileExists(atPath: cacheDirectory)
        if (!exist) {
            do {
                try fileManager.createDirectory(atPath: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            catch{
                Log.e(TAG(), "create \(cachePath) error: \(error.localizedDescription)")
                return false
            }
        }
        let existFile = fileManager.fileExists(atPath: cachePath)
        if !existFile {
            let isSuccess = fileManager.createFile(atPath: cachePath, contents: nil, attributes: nil)
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

    class func writeCache(_ account: DriveType, _ path: String, data: Data, _ position: UInt64) -> Int32 {
        let cachePath = NSHomeDirectory() + "/Library/Caches/" + account.rawValue + "/" + path
        let cacheDirectory = ConvertHelper.prePath(cachePath)
        let fileManager: FileManager = FileManager.default
        let cacheExist = fileManager.fileExists(atPath: cacheDirectory)
        if (!cacheExist) {
            do {
                try fileManager.createDirectory(atPath: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            catch{
                Log.e(TAG(), "create \(cachePath) error: \(error.localizedDescription)")
                return -1
            }
        }

        let existFile = fileManager.fileExists(atPath: cachePath)
        if !existFile {
            let isSuccess = fileManager.createFile(atPath: cachePath, contents: nil, attributes: nil)
            guard isSuccess else {
                Log.e(TAG(), "create \(cachePath) failed")
                return -1
            }
        }
        // copy-on-write
        let copyPath = NSHomeDirectory() + "/Library/Caches/" + account.rawValue + "/" + "copy-" + path
        do {
            let existFile = fileManager.fileExists(atPath: copyPath)
            if  !existFile {
                try fileManager.copyItem(atPath: cachePath, toPath: copyPath)
            }
        } catch {
            Log.e(TAG(), "writing failed")
            return -1
        }

        let writeHandle = FileHandle(forWritingAtPath: copyPath)
        writeHandle?.seek(toFileOffset: position)
        writeHandle?.write(data)
        return Int32(data.count)
    }

    class func readCache(_ account: DriveType, _ path: String, _ position: UInt64, _ length: Int) -> Data {
        let cachePath = NSHomeDirectory() + "/Library/Caches/" + account.rawValue + "/" + path
        let fileManager = FileManager.default
        let exist = fileManager.fileExists(atPath: cachePath)
        if (exist) {
            do {
                let readHandler = FileHandle(forReadingAtPath: cachePath)
                let attributes = try fileManager.attributesOfItem(atPath: cachePath)
                let fileSize = attributes[FileAttributeKey.size] as! UInt64
                var dt = Data()
                if position > fileSize {
                    Log.d(TAG(), "read finished")
                    return Data()
                }
                readHandler?.seek(toFileOffset: position)
                if fileSize <= length {
                    dt = readHandler?.readDataToEndOfFile() ?? Data()
                }
                else {
                    if fileSize >= position + UInt64(length)
                    {
                        dt = (readHandler?.readData(ofLength: length))!
                    }
                    else{
                        dt = (readHandler?.readDataToEndOfFile())!
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

    class func uploadFile(_ account: DriveType, _ path: String) -> Data  {
        let copyPath = NSHomeDirectory() + "/Library/Caches/" + account.rawValue + "/" + "copy-" + path
        let fileManager = FileManager.default
        let exist = fileManager.fileExists(atPath: copyPath)
        if (exist) {
            let readHandler = FileHandle(forReadingAtPath: copyPath)
            var dt = Data()
            readHandler?.seek(toFileOffset: 0)
            dt = (readHandler?.readDataToEndOfFile())!
            return dt
        }
        else { return Data() }
    }

    class func discardCache(_ account: DriveType, _ path: String) {
        let cachePath = NSHomeDirectory() + "/Library/Caches/" + account.rawValue + "/" + "copy-" + path
        let fileManager: FileManager = FileManager.default
        let exist = fileManager.fileExists(atPath: cachePath)
        if exist {
            do {
                try fileManager.removeItem(atPath: cachePath)
            }
            catch {}
        }
    }

    class func clearCacheAll() {

    }

    class func uploadCache(_ account: DriveType, _ path: String) {
        let cachePath = NSHomeDirectory() + "/Library/Caches/" + account.rawValue + "/" + path
        let copyPath = NSHomeDirectory() + "/Library/Caches/" + account.rawValue + "/" + "copy-" + path
        let fileManager: FileManager = FileManager.default
        let cacheExist = fileManager.fileExists(atPath: cachePath)
        let copyExist = fileManager.fileExists(atPath: copyPath)
        if copyExist && cacheExist {
            do {
                try fileManager.removeItem(atPath: cachePath)
                try fileManager.moveItem(atPath: copyPath, toPath: cachePath)
            }
            catch {
            }
        }
    }
}
