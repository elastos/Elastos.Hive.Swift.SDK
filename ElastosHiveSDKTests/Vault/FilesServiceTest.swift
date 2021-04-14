import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK


class FilesServiceTest: XCTestCase {
    
    private let FILE_NAME_TXT: String = "test_ios.txt"
    private let FILE_NAME_IMG: String = "big_ios.png"
    private let FILE_NAME_NOT_EXISTS: String = "not_exists.txt"
    
    private var bundlePath: Bundle?
    private var localTxtFilePath: String?
    private var localImgFilePath: String?
    private var localCacheRootDir: String?
    private var remoteRootDir: String?
    private var remoteTxtFilePath: String?
    private var remoteImgFilePath: String?
    private var remoteNotExistsFilePath: String?
    private var remoteBackupTxtFilePath: String?

    private var filesService: FilesProtocol?
    private var subscription: VaultSubscription?
    
    override func setUpWithError() throws {
        self.filesService = TestData.shared.newVault().filesService
        
        self.bundlePath = Bundle(for: type(of: self))
        self.localTxtFilePath = self.bundlePath?.path(forResource: "test_ios", ofType: "txt")
        self.localImgFilePath = self.bundlePath?.path(forResource: "big_ios", ofType: "png")
        
        self.remoteRootDir = "hive"
        self.remoteTxtFilePath = self.remoteRootDir! + "/" + FILE_NAME_TXT
        self.remoteImgFilePath = self.remoteRootDir! + "/" + FILE_NAME_IMG
        self.remoteNotExistsFilePath = self.remoteRootDir! + "/" + FILE_NAME_NOT_EXISTS
        self.remoteBackupTxtFilePath = "backup" + "/" + FILE_NAME_NOT_EXISTS
        
        let testData: TestData = TestData.shared;
        self.subscription = VaultSubscription(testData.appContext!, testData.providerAddress)
        self.filesService = testData.newVault().filesService
    }

    func test01UploadText() {
        let lock = XCTestExpectation(description: "wait for test upload text.")
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: self.localTxtFilePath!))
            self.filesService!.upload(self.remoteTxtFilePath!).done({ (fileWriter) in
                try fileWriter.write(data: data, { err in
                })
                fileWriter.close { (success, error) in
                    XCTAssert(success)
                    XCTAssert(error == nil)
                    lock.fulfill()
                }
            }).catch({ error in
                XCTFail("\(error)")
                lock.fulfill()
            })
            self.wait(for: [lock], timeout: 10000.0)

            let lockB = XCTestExpectation(description: "check verify remote file exists.")
            self.verifyRemoteFileExists(self.remoteTxtFilePath!).done { fileInfo in
                XCTAssert(fileInfo.size! > 0)
                lockB.fulfill()
            }.catch { error in
                XCTFail("\(error)")
                lockB.fulfill()
            }
            self.wait(for: [lockB], timeout: 10000.0)

        } catch {
            XCTFail("\(error)")
        }
    }

    func test02UploadBin() {
        do {
            let lock = XCTestExpectation(description: "wait for test upload bin.")
            let data = try Data(contentsOf: URL(fileURLWithPath: self.localImgFilePath!))
            self.filesService!.upload(self.remoteImgFilePath!).done({ (fileWriter) in
                try fileWriter.write(data: data, { err in
                    
                })
                fileWriter.close { (success, error) in
                    XCTAssert(success)
                    XCTAssert(error == nil)
                    lock.fulfill()
                }
            }).catch { error in
                XCTFail("\(error)")
                lock.fulfill()
            }
            self.wait(for: [lock], timeout: 10000.0)
            
            let lockB = XCTestExpectation(description: "check verify remote file exists.")
            self.verifyRemoteFileExists(self.remoteImgFilePath!).done { fileInfo in
                XCTAssert(fileInfo.size! > 0)
                lockB.fulfill()
            }.catch { error in
                XCTFail("\(error)")
                lockB.fulfill()
            }
            self.wait(for: [lockB], timeout: 10000.0)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test03DownloadText() {
        
        let lock = XCTestExpectation(description: "wait download txt file from remote.")
        self.filesService!.download(self.remoteTxtFilePath!).done({ [self] (reader) in
            let fileurl = createFilePathForDownload("test_ios_download.txt")
            while !reader.didLoadFinish {
                if let data = reader.read({ error in
                    XCTFail("\(error)")
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
            }
            
            let dir = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory,
                                               in: FileManager.SearchPathDomainMask.userDomainMask).last!
            let fileURL = dir.appendingPathComponent("test_ios_download.txt")
            let downloadData = try! Data(contentsOf: fileURL)
            let downloadString = String(data: downloadData, encoding: .utf8)
            
            
            let bundle = Bundle(for: type(of: self))
            let filePath: String = bundle.path(forResource: "test_ios", ofType: "txt")!
            let originalData = try! Data(contentsOf: URL(fileURLWithPath: filePath))
            let originalString = String(data: originalData, encoding: .utf8)
            
            XCTAssert(originalString == downloadString)
            lock.fulfill()
            
        }).catch { error in
            XCTFail("\(error)")
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 10000.0)
    }
    
    func test04DownloadBin() {
        let lock = XCTestExpectation(description: "wait download bin file from remote.")
        self.filesService!.download(self.remoteTxtFilePath!).done({ [self] (reader) in
            let fileurl = createFilePathForDownload("test_ios_download.txt")
            while !reader.didLoadFinish {
                if let data = reader.read({ error in
                    XCTFail("\(error)")
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
            }
            
            let dir = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory,
                                               in: FileManager.SearchPathDomainMask.userDomainMask).last!
            let fileURL = dir.appendingPathComponent("swift_download.png")
            let downloadData = try! Data(contentsOf: fileURL)
            let downloadPicString = String(data: downloadData, encoding: .utf8)
            
            
            let bundle = Bundle(for: type(of: self))
            let filePath: String = bundle.path(forResource: "big_ios", ofType: "png")!
            let originalData = try! Data(contentsOf: URL(fileURLWithPath: filePath))
            let originalPicString = String(data: originalData, encoding: .utf8)
            
            XCTAssert(downloadPicString == originalPicString)
            lock.fulfill()
            
        }).catch { error in
            XCTFail("\(error)")
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 10000.0)
    }
    
    func test05Hash() {
        let lock = XCTestExpectation(description: "wait get txt file hash code from remote.")
        self.filesService!.hash(self.remoteTxtFilePath!).get { hashCode in
            XCTAssert(hashCode.count > 0)
            lock.fulfill()
        }.catch { error in
            XCTFail("\(error)")
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 10000.0)
    }
    
    func test06Copy() {
        let lock = XCTestExpectation(description: "wait test copy.")
        self.filesService!.copy(self.remoteTxtFilePath!, self.remoteBackupTxtFilePath!).then({ isSuccess -> Promise<FileInfo> in
            return self.verifyRemoteFileExists(self.remoteBackupTxtFilePath!)
        }).done({ fileInfo in
            XCTAssert(fileInfo.size! > 0)
            lock.fulfill()
        }).catch { error in
            XCTFail("\(error)")
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 10000.0)
    }
    
    func test07DeleteFile() {
        let lock = XCTestExpectation(description: "wait test delete file.")
        self.filesService!.delete(self.remoteTxtFilePath!).then { isSuccess -> Promise<Bool> in
            return self.filesService!.delete(self.remoteBackupTxtFilePath!)
        }.then { isSuccess -> Promise<FileInfo> in
            return self.verifyRemoteFileExists(self.remoteTxtFilePath!)
        }.done { fileInfo in
            lock.fulfill()
        }.catch { error in
            XCTAssert("\(error)".contains("get error from server: error code = 404, message = file not exists"))
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 10000.0)
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

    func verifyRemoteFileExists(_ path: String) -> Promise<FileInfo> {
        return Promise<FileInfo> { resolver in
            self.filesService?.stat(path).done({ fileInfo in
                resolver.fulfill(fileInfo)
            }).catch({ error in
                resolver.reject(error)
            })
        }
    }
    
    
//
//    func testDeleteFile() {
//        self.filesService!.delete(self.remoteTxtFilePath!).then({ isSuccess -> Promise<Bool> in
//            return self.filesService!.delete(self.remoteBackupTxtFilePath!)
//        }).done { isSuccess in
//
//        }.catch { error in
//            XCTFail("\(error)")
//        }
//    }
//
//    func testRemoteFileNotExistsException() {
//        self.filesService!.hash(self.remoteNotExistsFilePath!).done { hashCode in
//
//        }.catch { error in
//            XCTFail("\(error)")
//        }
//    }
//
//    func testVaultLockException() {
//
//    }
//
//    private func uploadTextReally() {
//        self.filesService!.upload(self.remoteTxtFilePath!).done({ fileWriter in
//            let data = try Data(contentsOf: URL(fileURLWithPath: self.localTxtFilePath!))
//            try fileWriter.write(data: data, { err in
//            })
//            fileWriter.close { (success, error) in
//
//            }
//        }).catch { error in
//            XCTFail("\(error)")
//        }
//    }
    
//    private void uploadTextReally() throws IOException, ExecutionException, InterruptedException {
//        try (Writer writer = filesService.upload(remoteTxtFilePath, Writer.class).get();
//             FileReader fileReader = new FileReader(localTxtFilePath)) {
//            Assertions.assertNotNull(writer);
//            char[] buffer = new char[1];
//            while (fileReader.read(buffer) != -1) {
//                writer.write(buffer);
//            }
//        }
//    }
    
//    func test04_downloadBin()  {
//        let lock = XCTestExpectation(description: "wait download image.")
//        self.filesService?.download(self.remoteImgPath!).done({ [self] (reader) in
//            let fileurl = createFilePathForDownload("swift_download.png")
//            while !reader.didLoadFinish {
//                if let data = reader.read({ error in
//                    print(error)
//                }) {
//                    if let fileHandle = try? FileHandle(forWritingTo: fileurl) {
//                        fileHandle.seekToEndOfFile()
//                        fileHandle.write(data)
//                        fileHandle.closeFile()
//                    } else {
//                        XCTFail()
//                        lock.fulfill()
//                    }
//                }
//            }
//            reader.close { (success, error) in
//                success ? XCTAssert(success) : XCTFail()
//                lock.fulfill()
//            }
//        }).catch {[self] error in
//            try! testCaseFailAndThrowError(error, lock)
//        }
//        self.wait(for: [lock], timeout: 10000.0)
//    }
//
//    func test03_downloadText() throws {
//        let lock = XCTestExpectation(description: "wait download txt file from remote.")
//        self.filesService?.download(self.remoteTextPath!).done({ [self] (reader) in
//            let fileurl = createFilePathForDownload("test_ios_download.txt")
//            while !reader.didLoadFinish {
//                if let data = reader.read({ error in
//                    print(error)
//                }) {
//                    if let fileHandle = try? FileHandle(forWritingTo: fileurl) {
//                        fileHandle.seekToEndOfFile()
//                        fileHandle.write(data)
//                        fileHandle.closeFile()
//                    } else {
//                        XCTFail()
//                        lock.fulfill()
//                    }
//                }
//            }
//            reader.close { (success, error) in
//                success ? XCTAssert(success) : XCTFail()
//                lock.fulfill()
//            }
//        }).catch {[self] error in
//            try! testCaseFailAndThrowError(error, lock)
//        }
//        self.wait(for: [lock], timeout: 10000.0)
//    }
//
//    func test05_list() throws {
//        let lock = XCTestExpectation(description: "wait get list info.")
//        self.filesService?.list(self.remoteRootPath!).done({ (result) in
//            XCTAssert(result.count > 0)
//            lock.fulfill()
//        }).catch({[self] error in
//            try! testCaseFailAndThrowError(error, lock)
//        })
//        self.wait(for: [lock], timeout: 10000.0)
//    }
//
//    func test06_hash() throws {
//        let lock = XCTestExpectation(description: "check txt file hash code.")
//        self.filesService?.hash(self.remoteTextPath!).done({ (hash) in
//            XCTAssert(hash.count > 0)
//            lock.fulfill()
//        }).catch({[self] (error) in
//            try! testCaseFailAndThrowError(error, lock)
//        })
//        self.wait(for: [lock], timeout: 10000.0)
//    }
//
//    func test07_move() throws {
//        let lock = XCTestExpectation(description: "wait for test.")
//        self.filesService!.delete(self.remoteTextBackupPath!).then({ (result) -> Promise<Bool> in
//            return self.filesService!.move(self.remoteTextPath!, self.remoteTextBackupPath!)
//        }).done { (result) in
//            self.filesService!.download(self.remoteTextBackupPath!).done({ [self] (reader) in
//                let fileurl = createFilePathForDownload("swift_download_1.txt")
//                while !reader.didLoadFinish {
//                    if let data = reader.read({ error in
//                        print(error)
//                    }){
//                        if let fileHandle = try? FileHandle(forWritingTo: fileurl) {
//                            fileHandle.seekToEndOfFile()
//                            fileHandle.write(data)
//                            fileHandle.closeFile()
//                        } else {
//                            XCTFail()
//                            lock.fulfill()
//                        }
//                    }
//                }
//                reader.close { (success, error) in
//                    success ? XCTAssert(success) : XCTFail()
//                    lock.fulfill()
//                }
//            }).catch({[self] (error) in
//                try! testCaseFailAndThrowError(error, lock)
//            })
//        }.catch({[self] (error) in
//            try! testCaseFailAndThrowError(error, lock)
//        })
//        self.wait(for: [lock], timeout: 10000.0)
//    }
//
//
//    func test08_copy() throws {
//        let lock = XCTestExpectation(description: "wait copy file.")
//        self.filesService?.copy(self.remoteTextBackupPath!, self.remoteTextPath!).done({ (result) in
//            XCTAssert(result)
//            lock.fulfill()
//        }).catch({[self] (error) in
//            try! testCaseFailAndThrowError(error, lock)
//        })
//        self.wait(for: [lock], timeout: 10000.0)
//    }
//
//    func test09_deleteFile() throws {
//        let lock = XCTestExpectation(description: "wait delete file.")
//        self.filesService?.delete(self.remoteTextPath!).done({ (result) in
//            XCTAssert(result)
//            lock.fulfill()
//        }).catch({[self] (error) in
//            try! testCaseFailAndThrowError(error, lock)
//        })
//        self.wait(for: [lock], timeout: 10000.0)
//    }
//
//    func verifyRemoteFileExists(_ path: String) -> Promise<Bool> {
//        return self.filesService!.stat(path).then({ (fileInfo) -> Promise<Bool> in
//            return Promise<Bool> { resolver in
//                resolver.fulfill(fileInfo.size! > 0)
//            }
//        })
//    }
//

    

}
