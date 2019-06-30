

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
        hiveClient = HiveClientHandle.sharedInstance(type: .hiveIPFS)
    }

    func testA_login() {
        lock = XCTestExpectation(description: "wait for testA_login")

        let globalQueue = DispatchQueue.global()
        globalQueue.async {
            do {
                _ = try self.hiveClient?.login(self as Authenticator)
                self.lock?.fulfill()
            }catch {
                XCTFail()
                self.lock?.fulfill()
            }
        }
        wait(for: [lock!], timeout: timeOut)
    }

    func testB_lastUpdatedInfo() {
        lock = XCTestExpectation(description: "wait for testB_lastUpdatedInfo")
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

    func testC_RootDirectoryHandle() {

        lock = XCTestExpectation(description: "wait for testC_RootDirectoryHandle")
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

        lock = XCTestExpectation(description: "wait for testD_CreateDirectory")
        timeTest = Timestamp.getTimeAtNow()
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
        lock = XCTestExpectation(description: "wait for testE_directoryHandle")
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
        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for testF_createFile")
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

        lock = XCTestExpectation(description: "wait for testG_GetFileHandle")
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

    func testH_getItemInfo() {

        lock = XCTestExpectation(description: "wait for testH_getItemInfo")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveItemInfo> in
            return drive.getItemInfo("/hiveIpfs_Drive_test6_createFile_\(timeTest!)")
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
