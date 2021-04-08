import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

extension XCTestCase {
    func testCaseFailAndThrowError(_ error: Error, _ lock: XCTestExpectation?) throws {
        lock?.fulfill()
        XCTFail()
        throw error
    }
}

class FilesServiceTest: XCTestCase {
    var bundlePath: Bundle?
    var localRootPath: String?
    var textLocalPath: String?
    var imgLocalPath: String?
    var rootLocalCachePath: String?
    var textLocalCachePath: String?
    var imgLocalCachePath: String?
    var remoteRootPath: String?
    var remoteTextPath: String?
    var remoteImgPath: String?
    var remoteTextBackupPath: String?
    
    var filesService: FilesProtocol?
    
    func testUploadText() {
        let lock = XCTestExpectation(description: "wait for test upload text.")
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: self.textLocalPath!))
            self.filesService!.upload(self.remoteTextPath!).done({ (fileWriter) in
                try fileWriter.write(data: data, { err in
                })
                fileWriter.close { (success, error) in
                    print(success)
                    lock.fulfill()
                }
            }).catch({ error in
                XCTFail("\(error)")
            })
            self.wait(for: [lock], timeout: 10000.0)
            
            let lockB = XCTestExpectation(description: "check verify remote file exists.")
            self.verifyRemoteFileExists(self.remoteTextPath!).done { (result) in
                lockB.fulfill()
            }.catch { error in
                XCTFail("\(error)")
            }
            self.wait(for: [lockB], timeout: 10000.0)
            
        } catch {
            XCTFail("\(error)")
        }
       
    }
    
    
    func test02_uploadBin() throws {
        let lock = XCTestExpectation(description: "upload image.")
        let data = try Data(contentsOf: URL(fileURLWithPath: self.imgLocalPath!))
        self.filesService?.upload(self.remoteImgPath!).done({ (fileWriter) in
            try fileWriter.write(data: data, { err in
            })
            fileWriter.close { (success, error) in
                print(success)
                lock.fulfill()
            }
        }).catch {[self] error in
            try! testCaseFailAndThrowError(error, lock)
        }
        self.wait(for: [lock], timeout: 10000.0)
        
        let lockB = XCTestExpectation(description: "check verify remote file exists.")
        self.verifyRemoteFileExists(self.remoteTextPath!).done { (result) in
            lockB.fulfill()
        }.catch {[self] error in
            try! testCaseFailAndThrowError(error, lockB)
        }
        self.wait(for: [lockB], timeout: 10000.0)
    }
    
    func test04_downloadBin()  {
        let lock = XCTestExpectation(description: "wait download image.")
        self.filesService?.download(self.remoteImgPath!).done({ [self] (reader) in
            let fileurl = createFilePathForDownload("swift_download.png")
            while !reader.didLoadFinish {
                if let data = reader.read({ error in
                    print(error)
                }) {
                    if let fileHandle = try? FileHandle(forWritingTo: fileurl) {
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data)
                        fileHandle.closeFile()
                    } else {
                        XCTFail()
                        lock.fulfill()
                    }
                }
            }
            reader.close { (success, error) in
                success ? XCTAssert(success) : XCTFail()
                lock.fulfill()
            }
        }).catch {[self] error in
            try! testCaseFailAndThrowError(error, lock)
        }
        self.wait(for: [lock], timeout: 10000.0)
    }
    
    func test03_downloadText() throws {
        let lock = XCTestExpectation(description: "wait download txt file from remote.")
        self.filesService?.download(self.remoteTextPath!).done({ [self] (reader) in
            let fileurl = createFilePathForDownload("test_ios_download.txt")
            while !reader.didLoadFinish {
                if let data = reader.read({ error in
                    print(error)
                }) {
                    if let fileHandle = try? FileHandle(forWritingTo: fileurl) {
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data)
                        fileHandle.closeFile()
                    } else {
                        XCTFail()
                        lock.fulfill()
                    }
                }
            }
            reader.close { (success, error) in
                success ? XCTAssert(success) : XCTFail()
                lock.fulfill()
            }
        }).catch {[self] error in
            try! testCaseFailAndThrowError(error, lock)
        }
        self.wait(for: [lock], timeout: 10000.0)
    }
    
    func test05_list() throws {
        let lock = XCTestExpectation(description: "wait get list info.")
        self.filesService?.list(self.remoteRootPath!).done({ (result) in
            XCTAssert(result.count > 0)
            lock.fulfill()
        }).catch({[self] error in
            try! testCaseFailAndThrowError(error, lock)
        })
        self.wait(for: [lock], timeout: 10000.0)
    }
    
    func test06_hash() throws {
        let lock = XCTestExpectation(description: "check txt file hash code.")
        self.filesService?.hash(self.remoteTextPath!).done({ (hash) in
            XCTAssert(hash.count > 0)
            lock.fulfill()
        }).catch({[self] (error) in
            try! testCaseFailAndThrowError(error, lock)
        })
        self.wait(for: [lock], timeout: 10000.0)
    }
    
    func test07_move() throws {
        let lock = XCTestExpectation(description: "wait for test.")
        self.filesService!.delete(self.remoteTextBackupPath!).then({ (result) -> Promise<Bool> in
            return self.filesService!.move(self.remoteTextPath!, self.remoteTextBackupPath!)
        }).done { (result) in
            self.filesService!.download(self.remoteTextBackupPath!).done({ [self] (reader) in
                let fileurl = createFilePathForDownload("swift_download_1.txt")
                while !reader.didLoadFinish {
                    if let data = reader.read({ error in
                        print(error)
                    }){
                        if let fileHandle = try? FileHandle(forWritingTo: fileurl) {
                            fileHandle.seekToEndOfFile()
                            fileHandle.write(data)
                            fileHandle.closeFile()
                        } else {
                            XCTFail()
                            lock.fulfill()
                        }
                    }
                }
                reader.close { (success, error) in
                    success ? XCTAssert(success) : XCTFail()
                    lock.fulfill()
                }
            }).catch({[self] (error) in
                try! testCaseFailAndThrowError(error, lock)
            })
        }.catch({[self] (error) in
            try! testCaseFailAndThrowError(error, lock)
        })
        self.wait(for: [lock], timeout: 10000.0)
    }
    
    
    func test08_copy() throws {
        let lock = XCTestExpectation(description: "wait copy file.")
        self.filesService?.copy(self.remoteTextBackupPath!, self.remoteTextPath!).done({ (result) in
            XCTAssert(result)
            lock.fulfill()
        }).catch({[self] (error) in
            try! testCaseFailAndThrowError(error, lock)
        })
        self.wait(for: [lock], timeout: 10000.0)
    }
    
    func test09_deleteFile() throws {
        let lock = XCTestExpectation(description: "wait delete file.")
        self.filesService?.delete(self.remoteTextPath!).done({ (result) in
            XCTAssert(result)
            lock.fulfill()
        }).catch({[self] (error) in
            try! testCaseFailAndThrowError(error, lock)
        })
        self.wait(for: [lock], timeout: 10000.0)
    }
    
    func verifyRemoteFileExists(_ path: String) -> Promise<Bool> {
        return self.filesService!.stat(path).then({ (fileInfo) -> Promise<Bool> in
            return Promise<Bool> { resolver in
                resolver.fulfill(fileInfo.size! > 0)
            }
        })
    }
    
    func createFilePathForDownload(_ downloadPath: String) -> URL {
        let dir = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last
        let fileurl = dir?.appendingPathComponent(downloadPath)
        if !FileManager.default.fileExists(atPath: fileurl!.path) {
            FileManager.default.createFile(atPath: fileurl!.path, contents: nil, attributes: nil)
        } else {
            try? FileManager.default.removeItem(atPath: fileurl!.path)
            FileManager.default.createFile(atPath: fileurl!.path, contents: nil, attributes: nil)
        }
        return fileurl!
    }
    
    override func setUpWithError() throws {
        let lockA = XCTestExpectation(description: "wait for test.")
        _ = TestData.shared.getVault().done { (vault) in
            self.filesService = vault.filesService
            _ = try vault.connectionManager.headers()
            lockA.fulfill()
        }
        self.wait(for: [lockA], timeout: 1000.0)
        
        self.bundlePath = Bundle(for: type(of: self))
        self.textLocalPath = self.bundlePath?.path(forResource: "test_ios", ofType: "txt")
        self.imgLocalPath = self.bundlePath?.path(forResource: "big_ios", ofType: "png")

        
        self.localRootPath = Bundle(for: type(of: self)).bundleURL.absoluteString
        self.rootLocalCachePath = self.localRootPath! + "cache/file/"
        self.textLocalCachePath = self.rootLocalCachePath! + "test.txt"
        self.imgLocalCachePath = self.rootLocalCachePath! + "/big_ios.png"

        self.remoteRootPath = "hive"
        self.remoteTextPath = self.remoteRootPath! + "/" + "test_ios.txt"
        self.remoteImgPath = self.remoteRootPath! + "/" + "big_ios.png"
        self.remoteTextBackupPath = "backup" + "/" + "test_ios.txt"
    }
}
