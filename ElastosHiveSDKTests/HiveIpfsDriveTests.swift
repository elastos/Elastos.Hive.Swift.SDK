

import XCTest
@testable import ElastosHiveSDK


class HiveIpfsDriveTests: XCTestCase, Authenticator{
    func requestAuthentication(_ requestURL: String) -> Bool {
        return true
    }

    var hiveClient: HiveClientHandle?
    var hiveParams: DriveParameter?
    var lock: XCTestExpectation?
    var timeOut: Double = 600.0

    override func setUp() {
        hiveParams = DriveParameter.createForIpfsDrive("uid-37dd2923-baf6-4aae-bc28-d4e5fd92a7b0", "/")
        HiveClientHandle.createInstance(hiveParams!)
        hiveClient = HiveClientHandle.sharedInstance(type: .hiveIpfs)
    }

    func testA_login() {
        lock = XCTestExpectation(description: "wait for test1_Login")

        let globalQueue = DispatchQueue.global()
        globalQueue.async {
            let result = self.hiveClient?.login(self as Authenticator)
            XCTAssertTrue(result!)
            self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeOut)
    }

    /*
    func testB_lastUpdatedInfo() {
        lock = XCTestExpectation(description: "wait for test2_lastUpdatedInfo")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDriveInfo> in
            return drive.lastUpdatedInfo()
        }).done({ (driveInfo) in
            XCTAssertNotNil(driveInfo)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeOut)
    }
 */

    func testC_RootDirectoryHandle() {

        lock = XCTestExpectation(description: "wait for test3_RootDirectoryHandle")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDirectoryHandle> in
            return drive.rootDirectoryHandle()
        }).done({ (directory) in
            XCTAssertNotNil(directory)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeOut)
    }

    func testD_CreateDirectory() {

        lock = XCTestExpectation(description: "wait for test4_CreateDirectory")
        timeTest = HelperMethods.getCurrentTime()
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDirectoryHandle> in
            return drive.createDirectory(withPath: "/hiveIpfs_Drive_test4_CreateDirectory_\(timeTest!)")
        }).done({ (directory) in
            XCTAssertNotNil(directory)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeOut)
    }

    func testE_directoryHandle() {
        lock = XCTestExpectation(description: "wait for test5_directoryHandle")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDirectoryHandle> in
            return drive.directoryHandle(atPath: "/hiveIpfs_Drive_test4_CreateDirectory_\(timeTest!)")
        }).done({ (directory) in
            XCTAssertNotNil(directory)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeOut)
    }

    func testF_createFile() {
        timeTest = HelperMethods.getCurrentTime()
        lock = XCTestExpectation(description: "wait for test6_createFile")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.createFile(withPath: "/hiveIpfs_Drive_test6_createFile_\(timeTest!)")
        }).done({ (file) in
            XCTAssertNotNil(file)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeOut)
    }

    func testG_GetFileHandle() {

        lock = XCTestExpectation(description: "wait for test7_GetFileHandle")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/hiveIpfs_Drive_test6_createFile_\(timeTest!)")
        }).done({ (file) in
            XCTAssertNotNil(file)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeOut)
    }

}
