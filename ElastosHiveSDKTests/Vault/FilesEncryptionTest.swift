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
import AwaitKit
import DeveloperDID

class FilesEncryptionTest: XCTestCase {
    
    private let FILE_NAME_TXT: String = "test_encryption_ios.txt"
    private let FILE_CONTENT_TXT = "This is a test file for encryption"
    private let FILE_NAME_BIN = "test_encryption.dat"
    private let FILE_CONTENT_BIN = "This is a binary test file for encryption"

    private var bundlePath: Bundle?
    private var localTxtFilePath: String?
    private var localImgFilePath: String?
    private var remoteRootDir: String?
    private var remoteTxtFilePath: String?
    private var remoteImgFilePath: String?
    private var remoteNotExistsFilePath: String?
    private var remoteNotExistsDirPath: String?
    private var remoteBackupTxtFilePath: String?
    private var localCacheImgPath: String?
    private var localCacheTxtPath: String?

    private var subscription: VaultSubscription?
    public var _filesService: FilesService?

    var cipher: DIDCipher?

    override func setUpWithError() throws {
        Log.setLevel(.Debug)
        let testData = TestData.shared()

        XCTAssertNoThrow(_filesService = try testData.getEncryptionFileService())
        do {
            cipher = try testData.getEncryptionCipher()
            let vaultSubscription = try VaultSubscription(testData.appContext,testData.providerAddress)
            try `await`(vaultSubscription.subscribe())
        } catch  {
            if let error = error as? HiveError {
                switch error {
                case .AlreadyExistsException:
                    XCTAssertTrue(true)
                default:
                    XCTAssertTrue(false)
                }
            }
        }
        
        self.bundlePath = Bundle(for: type(of: self))
        self.localTxtFilePath = self.bundlePath?.path(forResource: "test_ios", ofType: "txt")
        self.localImgFilePath = self.bundlePath?.path(forResource: "big_ios", ofType: "png")
        
        self.remoteRootDir = "hive"
        self.remoteTxtFilePath = self.remoteRootDir! + "/" + FILE_NAME_TXT
        self.localCacheTxtPath = "test_download_encryption_ios.txt"
        
        self.remoteNotExistsDirPath = remoteNotExistsFilePath
    }
    
    public func test01UploadText() {
        XCTAssertNoThrow(try { [self] in
            try uploadTextReally()
            verifyRemoteFileExists(self.remoteTxtFilePath!)
        }())
    }
    
    private func uploadTextReally() throws {
        XCTAssertNoThrow(try { [self] in
            let data = try Data(contentsOf: URL(fileURLWithPath: self.localTxtFilePath!))
            let fileWriter = try `await`(_filesService!.getUploadWriter(remoteTxtFilePath!))
            let result = try `await`(fileWriter.write(data: data))
            XCTAssertTrue(result)
        }())
    }
    
    func verifyRemoteFileExists(_ path: String) {
        XCTAssertNoThrow(try { [self] in
            XCTAssertNotNil(try `await`(_filesService!.stat(path)))
        }())
    }
    
    func test02DownloadText() {
        XCTAssertNoThrow(try { [self] in
            let reader = try `await`(_filesService!.getDownloadReader(self.remoteTxtFilePath!))
            let targetUrl = createFilePathForDownload(self.localCacheTxtPath!)
            let result = try `await`(reader.read(targetUrl))
            XCTAssertTrue(result)
            let isEqual = try self.isFileContentEqual(self.localTxtFilePath!, self.localCacheTxtPath!)
            XCTAssertTrue(isEqual)
        }())
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
        print(fileurl)
        return fileurl!
    }
    
    public func isFileContentEqual(_ srcFile: String, _ dstFile: String) throws -> Bool {
        let dir = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory,
                                           in: FileManager.SearchPathDomainMask.userDomainMask).last!
        let fileURL = dir.appendingPathComponent(dstFile)
        let downloadData = try! Data(contentsOf: fileURL)
        let originalData = try Data(contentsOf: URL(fileURLWithPath: srcFile))
        
        return downloadData == originalData
    }
    
    /*
    public func test02UploadBin() {
        XCTAssertNoThrow(try { [self] in
            let data = try Data(contentsOf: URL(fileURLWithPath: self.localImgFilePath!))
            let fileWriter = try `await`(_filesService!.getUploadWriter(self.remoteImgFilePath!))
            let result = try `await`(fileWriter.write(data: data))
            XCTAssertTrue(result)
        }())
    }

    func test03DownloadText() {
        XCTAssertNoThrow(try { [self] in
            let reader = try `await`(_filesService!.getDownloadReader(self.remoteTxtFilePath!))
            let targetUrl = createFilePathForDownload(self.localCacheTxtPath!)
            let result = try `await`(reader.read(targetUrl))
            XCTAssertTrue(result)
            let isEqual = try self.isFileContentEqual(self.localTxtFilePath!, self.localCacheTxtPath!)
            XCTAssertTrue(isEqual)
        }())
    }

    public func test04DownloadBin() {
        XCTAssertNoThrow(try { [self] in
            let reader = try `await`(_filesService!.getDownloadReader(self.remoteImgFilePath!))
            let fileurl = createFilePathForDownload(self.localCacheImgPath!)
            let result = try `await`(reader.read(fileurl))
            XCTAssertTrue(result)
            let isEqual = try self.isFileContentEqual(self.localImgFilePath!, self.localCacheImgPath!)
            XCTAssertTrue(isEqual)

        }())
    }
    
    public func test04DownloadBin4NotFoundException() {
        do {
            let reader = try `await`(_filesService!.getDownloadReader(self.remoteNotExistsFilePath!))
            let fileurl = createFilePathForDownload("swift_download.png")
            let result = try `await`(reader.read(fileurl))
            XCTAssertTrue(result)
        } catch {
            if let error = error as? HiveError {
                switch error {
                case .NotFoundException:
                    XCTAssertTrue(true)
                default:
                    XCTAssertTrue(false)
                }
            }
        }
    }*/
    /*
    public func test05List() {
        XCTAssertNoThrow(try { [self] in
            let files = try `await`(_filesService!.list(self.remoteRootDir!))
            XCTAssertNotNil(files)
            XCTAssertTrue(files.count >= 2)
            var fileInfos = [String]()
            for fileInfo in files {
                fileInfos.append(fileInfo.name!)
            }
            XCTAssertTrue(fileInfos.contains(FILE_NAME_TXT))
            XCTAssertTrue(fileInfos.contains(FILE_NAME_IMG))
        }())
    }
    
    public func test05List4NotFoundException() {
        do {
            _ = try `await`(_filesService!.list(self.remoteNotExistsDirPath!))
        } catch  {
            if let error = error as? HiveError {
                switch error {
                case .NotFoundException:
                    XCTAssertTrue(true)
                default:
                    XCTAssertTrue(false)
                }
            }
        }
    }
    
    public func test06Hash() {
        XCTAssertNoThrow(try { [self] in
            XCTAssertTrue(try `await`(_filesService!.hash(self.remoteTxtFilePath!)).count > 0)
        }())
    }

    public func test06Hash4NotFoundException() {
        do {
            _ = try `await`(_filesService!.hash(self.remoteNotExistsDirPath!))
        } catch  {
            if let error = error as? HiveError {
                switch error {
                case .NotFoundException:
                    XCTAssertTrue(true)
                default:
                    XCTAssertTrue(false)
                }
            }
        }
    }
    
    public func test07Move() {
        XCTAssertNoThrow(try { [self] in
            _ = try `await`(_filesService!.delete(self.remoteBackupTxtFilePath!))
            _ = try `await`(_filesService!.move(self.remoteTxtFilePath!, self.remoteBackupTxtFilePath!))
            verifyRemoteFileExists(self.remoteBackupTxtFilePath!)
        }())
    }
    
    public func test07Move4NotFoundException() {
        do {
            _ = try `await`(_filesService!.move(self.remoteNotExistsFilePath!, self.remoteNotExistsFilePath! + "_bak"))
        } catch  {
            if let error = error as? HiveError {
                switch error {
                case .NotFoundException:
                    XCTAssertTrue(true)
                default:
                    XCTAssertTrue(false)
                }
            }
        }
    }
    
    public func test08Copy() {
        XCTAssertNoThrow(try { [self] in
            _ = try `await`(_filesService!.copy(self.remoteBackupTxtFilePath!, self.remoteTxtFilePath!))
            verifyRemoteFileExists(self.remoteTxtFilePath!)
        }())
    }
    
    public func test08Copy4NotFoundException() {
        do {
            _ = try `await`(_filesService!.copy(self.remoteNotExistsFilePath!, self.remoteNotExistsFilePath! + "_bak"))
        } catch  {
            if let error = error as? HiveError {
                switch error {
                case .NotFoundException:
                    XCTAssertTrue(true)
                default:
                    XCTAssertTrue(false)
                }
            }
        }
    }
    
    public func test09DeleteFile() {
        XCTAssertNoThrow(try { [self] in
            _ = try `await`(_filesService!.delete(self.remoteTxtFilePath!))
            _ = try `await`(_filesService!.delete(self.remoteBackupTxtFilePath!))
        }())
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
        print(fileurl)
        return fileurl!
    }
    
    func verifyRemoteFileExists(_ path: String) {
        XCTAssertNoThrow(try { [self] in
            XCTAssertNotNil(try `await`(_filesService!.stat(path)))
        }())
    }
    
    public func isFileContentEqual(_ srcFile: String, _ dstFile: String) throws -> Bool {
        let dir = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory,
                                           in: FileManager.SearchPathDomainMask.userDomainMask).last!
        let fileURL = dir.appendingPathComponent(dstFile)
        let downloadData = try! Data(contentsOf: fileURL)
        let originalData = try Data(contentsOf: URL(fileURLWithPath: srcFile))
        
        return downloadData == originalData
    }


    public func test10UploadPublicBin() {
        XCTAssertNoThrow(try { [self] in
            let fileName = FILE_PUBLIC_NAME_TXT
            let length = FILE_PUBLIC_NAME_TXT.count - 4
            let scriptName = FILE_PUBLIC_NAME_TXT.prefix(length)
            print("scriptName \(scriptName)")
            var cid = "Qmc4toiRA9NsCUEFgkdKDAeUkEj6UQzA4r9AXrtgaDX4CS"
            
            // Upload public file.
            let fileWriter =  try `await`(_filesService!.getUploadWriter(fileName, String(scriptName)))
            var result = try `await`(fileWriter.write(data: FILE_PUBLIC_NAME_TXT.data(using: .utf8)!))
            cid = fileWriter.cid!
            print("result ======= \(result)")

            // Download and verify normally.
            let reader = try `await`(_filesService!.getDownloadReader(fileName))
            let targetUrl = createFilePathForDownload(fileName)
            result = try `await`(reader.read(targetUrl))
            XCTAssertTrue(result)
//
            // Download by cid.
            let ipfsTargetUrl = createFilePathForDownload("download_\(fileName)")
            let ipfsReader = try `await`(IpfsRunner(ipfsGatewayUrl: TestData.shared().getIpfsGatewayUrl()).getFileReader(cid))
            _ = try `await`(ipfsReader.read(ipfsTargetUrl))
            
        }())
    }*/
}

