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

import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK
import AwaitKit


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

    private var _filesService: FilesService?
    private var subscription: VaultSubscription?
    
    override func setUpWithError() throws {
        let testData: TestData = TestData.shared();

        _filesService = try testData.newVault().filesService
        
        self.bundlePath = Bundle(for: type(of: self))
        self.localTxtFilePath = self.bundlePath?.path(forResource: "test_ios", ofType: "txt")
        self.localImgFilePath = self.bundlePath?.path(forResource: "big_ios", ofType: "png")
        
        self.remoteRootDir = "hive"
        self.remoteTxtFilePath = self.remoteRootDir! + "/" + FILE_NAME_TXT
        self.remoteImgFilePath = self.remoteRootDir! + "/" + FILE_NAME_IMG
        self.remoteNotExistsFilePath = self.remoteRootDir! + "/" + FILE_NAME_NOT_EXISTS
        self.remoteBackupTxtFilePath = "backup" + "/" + FILE_NAME_NOT_EXISTS
        
        self.subscription = try VaultSubscription(testData.appContext, testData.providerAddress)
        _filesService = try testData.newVault().filesService
    }
    
    public func test01UploadText() {
        
    }
    
    private func uploadTextReally() throws {
        do {
            let lock = XCTestExpectation(description: "wait for test upload bin.")
            let data = try Data(contentsOf: URL(fileURLWithPath: self.localImgFilePath!))
            let fileWriter = try await(_filesService!.getUploadWriter(remoteImgFilePath!))
            try fileWriter.write(data: data, { err in
                
            })
            fileWriter.close { (success, error) in
                
            }
        } catch {
            print(error)
        }
       
    }
    
//    @Test @Order(5) void testList() {
//        Assertions.assertDoesNotThrow(() -> {
//            List<FileInfo> files = filesService.list(remoteRootDir).get();
//            Assertions.assertNotNull(files);
//            Assertions.assertTrue(files.size() >= 2);
//            List<String> names = files.stream().map(FileInfo::getName).collect(Collectors.toList());
//            Assertions.assertTrue(names.contains(FILE_NAME_TXT));
//            Assertions.assertTrue(names.contains(FILE_NAME_IMG));
//        });
//    }

    public func testList() {
        XCTAssertNoThrow(try { [self] in
            XCTAssertNotNil(try await(_filesService!.hash(self.remoteTxtFilePath!)))
        }())
    }

    public func test06Hash() {
        XCTAssertNoThrow({ [self] in
            XCTAssertNotNil(try await(_filesService!.hash(self.remoteTxtFilePath!)))
        })
    }
    
    public func test07Move() {
        XCTAssertNoThrow({ [self] in
            _ = try await(_filesService!.delete(self.remoteBackupTxtFilePath!))
            _ = try await(_filesService!.move(self.remoteTxtFilePath!, self.remoteBackupTxtFilePath!))
            verifyRemoteFileExists(self.remoteBackupTxtFilePath!)
        })
    }
    
    public func test08Copy() {
        XCTAssertNoThrow({ [self] in
            _ = try await(_filesService!.copy(self.remoteBackupTxtFilePath!, self.remoteTxtFilePath!))
            verifyRemoteFileExists(self.remoteTxtFilePath!)
        })
    }
    
    func test09DeleteFile() {
        XCTAssertNoThrow({ [self] in
            _ = try await(_filesService!.delete(self.remoteTxtFilePath!))
            _ = try await(_filesService!.delete(self.remoteBackupTxtFilePath!))
        })
    }
    
    func verifyRemoteFileExists(_ path: String) {
        XCTAssertNoThrow({ [self] in
            XCTAssertNotNil(try await(_filesService!.stat(path)))
        })
    }

    
//    private void uploadTextReally() throws IOException, ExecutionException, InterruptedException {
//            try (Writer writer = filesService.getUploadWriter(remoteTxtFilePath).get();
//                 FileReader fileReader = new FileReader(localTxtFilePath)) {
//                Assertions.assertNotNull(writer);
//                char[] buffer = new char[1];
//                while (fileReader.read(buffer) != -1) {
//                    writer.write(buffer);
//                }
//            }
//        }
    
//    @Test @Order(1) void testUploadText() {

        
//    @Test @Order(2) void testUploadBin() {
//        try (OutputStream out = filesService.getUploadStream(remoteImgFilePath).get()) {
//            Assertions.assertNotNull(out);
//            out.write(Utils.readImage(localImgFilePath));
//            out.flush();
//        } catch (Exception e) {
//            Assertions.fail(Throwables.getStackTraceAsString(e));
//        }
//        verifyRemoteFileExists(remoteImgFilePath);
//    }

    func test02UploadBin() {
        do {
            let lock = XCTestExpectation(description: "wait for test upload bin.")
            let data = try Data(contentsOf: URL(fileURLWithPath: self.localImgFilePath!))
            let fileWriter = try await(_filesService!.getUploadWriter(remoteImgFilePath!))
            try fileWriter.write(data: data, { err in
                
            })
            fileWriter.close { (success, error) in
                
            }
            
            
//            let data = try Data(contentsOf: URL(fileURLWithPath: self.localImgFilePath!))
//            self.filesService!.upload(self.remoteImgFilePath!).done({ (fileWriter) in
//                try fileWriter.write(data: data, { err in
//
//                })
//                fileWriter.close { (success, error) in
//                    XCTAssert(success)
//                    XCTAssert(error == nil)
//                    lock.fulfill()
//                }
//            }).catch { error in
//                XCTFail("\(error)")
//                lock.fulfill()
//            }
//            self.wait(for: [lock], timeout: 10000.0)
//
//            let lockB = XCTestExpectation(description: "check verify remote file exists.")
//            self.verifyRemoteFileExists(self.remoteImgFilePath!).done { fileInfo in
//                XCTAssert(fileInfo.size > 0)
//                lockB.fulfill()
//            }.catch { error in
//                XCTFail("\(error)")
//                lockB.fulfill()
//            }
//            self.wait(for: [lockB], timeout: 10000.0)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    /*
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
                XCTAssert(fileInfo.size > 0)
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
                XCTAssert(fileInfo.size > 0)
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
        self.filesService!.download(self.remoteImgFilePath!).done({ [self] (reader) in
            let fileurl = createFilePathForDownload("swift_download.png")
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
        
        self.filesService!.delete(self.remoteBackupTxtFilePath!).then { isSuccess -> Promise<Bool> in
            return self.filesService!.copy(self.remoteTxtFilePath!, self.remoteBackupTxtFilePath!)
        }.then({ isSuccess -> Promise<FileInfo> in
            return self.verifyRemoteFileExists(self.remoteBackupTxtFilePath!)
        }).done({ fileInfo in
            XCTAssert(fileInfo.size > 0)
            lock.fulfill()
        }).catch { error in
            XCTFail("\(error)")
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 10000.0)
    }
    
    func test07List() {
        let lock = XCTestExpectation(description: "wait get list info.")
        self.filesService!.list(self.remoteRootDir!).done({ (result) in
            XCTAssert(result.count > 0)
            lock.fulfill()
        }).catch({ error in
            XCTFail("\(error)")
            lock.fulfill()
        })
        self.wait(for: [lock], timeout: 10000.0)
    }
    
    func test08Move() {
        let lock = XCTestExpectation(description: "wait for test.")
        self.filesService!.delete(self.remoteBackupTxtFilePath!).then({ (result) -> Promise<Bool> in
            return self.filesService!.move(self.remoteTxtFilePath!, self.remoteBackupTxtFilePath!)
        }).done { isSuccess in
            self.filesService!.download(self.remoteBackupTxtFilePath!).done({ reader in
                do {
                    let fileurl = self.createFilePathForDownload("swift_download_1.txt")
                    while !reader.didLoadFinish {
                        if let data = reader.read({ error in
                            XCTFail("\(error)")
                            lock.fulfill()
                        }){
                            let fileHandle = try FileHandle(forWritingTo: fileurl)
                            fileHandle.seekToEndOfFile()
                            fileHandle.write(data)
                            fileHandle.closeFile()
                        }
                    }
                    reader.close { (success, error) in
                        XCTAssertFalse(error != nil)
                    }
                    
                    let dir = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory,
                                                       in: FileManager.SearchPathDomainMask.userDomainMask).last!
                    let backupTxtURL = dir.appendingPathComponent("swift_download_1.txt")
                    let backupTxtData = try Data(contentsOf: backupTxtURL)
                    let backupTxtString = String(data: backupTxtData, encoding: .utf8)
  
                    let bundle = Bundle(for: type(of: self))
                    let srcTxtURL: String = bundle.path(forResource: "test_ios", ofType: "txt")!
                    let srcTxtData = try! Data(contentsOf: URL(fileURLWithPath: srcTxtURL))
                    let srcTxtString = String(data: srcTxtData, encoding: .utf8)
                    
                    XCTAssert(backupTxtString == srcTxtString)
                    lock.fulfill()
                } catch {
                    XCTFail("\(error)")
                    lock.fulfill()
                }
            }).catch({ (error) in
                XCTFail("\(error)")
                lock.fulfill()
            })
        }.catch({ error in
            XCTFail("\(error)")
            lock.fulfill()
        })
        self.wait(for: [lock], timeout: 10000.0)
    }
    
    
    func test09DeleteFile() {
        let lock = XCTestExpectation(description: "wait test delete file.")
        self.filesService!.delete(self.remoteTxtFilePath!).then { isSuccess -> Promise<Bool> in
            return self.filesService!.delete(self.remoteBackupTxtFilePath!)
        }.then { isSuccess -> Promise<FileInfo> in
            return self.filesService!.stat(self.remoteTxtFilePath!)
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
    */
}

