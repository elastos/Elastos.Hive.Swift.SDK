

import XCTest
@testable import ElastosHiveSDK

class HiveIpfsFileTests: XCTestCase, Authenticator{
    func requestAuthentication(_ requestURL: String) -> Bool {
        return true
    }
    var hiveClient: HiveClientHandle?
    var hiveParams: DriveParameter?
    var lock: XCTestExpectation?
    let timeout: Double = 600.0

    override func setUp() {
        hiveParams = DriveParameter.createForIpfsDrive("uid-37dd2923-baf6-4aae-bc28-d4e5fd92a7b0", "/")
        HiveClientHandle.createInstance(hiveParams!)
        hiveClient = HiveClientHandle.sharedInstance(type: .hiveIpfs)
    }

    override func tearDown() {
    }

    func testA_Login() {
        lock = XCTestExpectation(description: "wait for test1_Login")

        let globalQueue = DispatchQueue.global()
        globalQueue.async {
            do {
                let result = try self.hiveClient?.login(self as Authenticator)
                XCTAssertTrue(result!)
                self.lock?.fulfill()
            }catch {
                XCTFail()
                self.lock?.fulfill()
            }
        }
        wait(for: [lock!], timeout: timeout)
    }

    func testB_creatFile() {

        timeTest = HelperMethods.getCurrentTime()
        lock = XCTestExpectation(description: "wait for test2_creatFile")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.createFile(withPath: "/hiveIpfs_File_test2_creatFile_\(timeTest!)")
        }).done({ (file) in
            XCTAssertNotNil(file)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func testC_lastUpdatedInfo() {

        lock = XCTestExpectation(description: "wait for test3_lastUpdatedInfo")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/hiveIpfs_File_test2_creatFile_\(timeTest!)")
        }).then({ (file) -> HivePromise<HiveFileInfo> in
            return file.lastUpdatedInfo()
        }).done({ (fileInfo) in
            XCTAssertNotNil(fileInfo)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func testD_copyTo() {

        // copy
        lock = XCTestExpectation(description: "wait for test4_preCreate")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDirectoryHandle> in
            return drive.createDirectory(withPath: "/\(timeTest!)")
        }).done({ (re) in
            XCTAssertNotNil(re)
            self.lock?.fulfill()
        }).catch({ (err) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)

        lock = XCTestExpectation(description: "wait for test4_copyTo")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/hiveIpfs_File_test2_creatFile_\(timeTest!)")
        }).then({ (file) -> HivePromise<Bool> in
            return file.copyTo(newPath: "/\(timeTest!)/hiveIpfs_File_test2_creatFile_\(timeTest!)")
        }).done({ (re) in
            XCTAssertTrue(re)
            self.lock?.fulfill()
        }).catch({ (err) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func testE_deleteItem() {
        // delete
        lock = XCTestExpectation(description: "wait for test5_deleteItem")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/hiveIpfs_File_test2_creatFile_\(timeTest!)")
        }).then({ (file) -> HivePromise<Bool> in
            return file.deleteItem()
        }).done({ (re) in
            XCTAssertTrue(re)
            self.lock?.fulfill()
        }).catch({ (err) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func testF_moveTo() {
        // move
        lock = XCTestExpectation(description: "wait for test6_moveTo")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/\(timeTest!)/hiveIpfs_File_test2_creatFile_\(timeTest!)")
        }).then({ (file) -> HivePromise<Bool> in
            return file.moveTo(newPath: "/")
        }).done({ (re) in
            XCTAssertTrue(re)
            self.lock?.fulfill()
        }).catch({ (err) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    /*
    func testG_writeData() {

        lock = XCTestExpectation(description: "wait for test7_writeData")
        let data = "ios test for write \(timeTest!)".data(using: .utf8)
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/hiveIpfs_File_test2_creatFile_\(timeTest!)")
        }).then({ (file) -> HivePromise<Bool> in
            return file.writeData(withData: data!)
        }).done({ (re) in
            XCTAssertTrue(re)
            self.lock?.fulfill()
        }).catch({ (er) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func testH_readData() {
        lock = XCTestExpectation(description: "wait for test8_readData")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/hiveIpfs_File_test2_creatFile_\(timeTest!)0")
        }).then({ (file) -> HivePromise<String> in
            return file.readData()
        }).done({ (content) in
            XCTAssertEqual(content, "ios test for write \(timeTest!)")
            self.lock?.fulfill()
        }).catch({ (er) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }
*/
}
