

import XCTest
@testable import ElastosHiveSDK

class HiveIpfsDirectoryTests: XCTestCase, Authenticator{
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

    func test1_Login() {
        lock = XCTestExpectation(description: "wait for test1_Login")

        let globalQueue = DispatchQueue.global()
        globalQueue.async {
            let result = self.hiveClient?.login(self as Authenticator)
            XCTAssertTrue(result!)
            self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)
    }

    /*
    func test2_lastUpdatedInfo() {
        lock = XCTestExpectation(description: "wait for test2_lastUpdatedInfo")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDirectoryHandle> in
            return drive.rootDirectoryHandle()
        }).then({ (directory) -> HivePromise<HiveDirectoryInfo> in
            return directory.lastUpdatedInfo()
        }).done({ (directoryInfo) in
            XCTAssertNotNil(directoryInfo)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }
 */

    func test3_createDirectory() {
        timeTest = HelperMethods.getCurrentTime()
        lock = XCTestExpectation(description: "wait for test3_createDirectory")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDirectoryHandle> in
            return drive.rootDirectoryHandle()
        }).then({ (directory) -> HivePromise<HiveDirectoryHandle> in
            return directory.createDirectory(withPath: "hiveIpfs_Directory_test3_createDirectory\(timeTest!)")
        }).done({ (directory) in
            XCTAssertNotNil(directory)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test4_directoryHandle() {
        lock = XCTestExpectation(description: "wait for test4_directoryHandle")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDirectoryHandle> in
            return drive.rootDirectoryHandle()
        }).then({ (directory) -> HivePromise<HiveDirectoryHandle> in
            return directory.directoryHandle(atPath: "hiveIpfs_Directory_test3_createDirectory\(timeTest!)")
        }).done({ (directory) in
            XCTAssertNotNil(directory)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test5_createFile() {
        lock = XCTestExpectation(description: "wait for test5_createFile")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDirectoryHandle> in
            return drive.rootDirectoryHandle()
        }).then({ (directory) -> HivePromise<HiveFileHandle> in
            directory.createFile(withPath: "hiveIpfs_Directory_test5_createFile\(timeTest!)")
        }).done({ (file) in
            XCTAssertNotNil(file)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test6_fileHandle() {
        lock = XCTestExpectation(description: "wait for test6_fileHandle")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDirectoryHandle> in
            return drive.rootDirectoryHandle()
        }).then({ (directory) -> HivePromise<HiveFileHandle> in
            return directory.fileHandle(atPath: "hiveIpfs_Directory_test5_createFile\(timeTest!)")
        }).done({ (file) in
            XCTAssertNotNil(file)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test7_getChildren() {
        lock = XCTestExpectation(description: "wait for test7_getChildren")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDirectoryHandle> in
            return drive.rootDirectoryHandle()
        }).then({ (directory) -> HivePromise<HiveChildren> in
            return directory.getChildren()
        }).done({ (children) in
            XCTAssertNotNil(children)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test8_copyTo() {
        lock = XCTestExpectation(description: "wait for test8_precreate_directory")
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

        lock = XCTestExpectation(description: "wait for test8_copyTo")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDirectoryHandle> in
            return drive.directoryHandle(atPath: "/hiveIpfs_Directory_test3_createDirectory\(timeTest!)")
        }).then({ (directory) -> HivePromise<Bool> in
            return directory.copyTo(newPath: "/\(timeTest!)/hiveIpfs_Directory_test3_createDirectory\(timeTest!)")
        }).done({ (re) in
            XCTAssertTrue(re)
            self.lock?.fulfill()
        }).catch({ (err) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test9_deleteItem() {
        lock = XCTestExpectation(description: "wait for test9_deleteItem")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDirectoryHandle> in
            return drive.directoryHandle(atPath: "/hiveIpfs_Directory_test3_createDirectory\(timeTest!)")
        }).then({ (directory) -> HivePromise<Bool> in
            return directory.deleteItem()
        }).done({ (re) in
            XCTAssertTrue(re)
            self.lock?.fulfill()
        }).catch({ (err) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test10_moveTo() {
        lock = XCTestExpectation(description: "wait for test10_moveTo")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDirectoryHandle> in
            return drive.directoryHandle(atPath: "/\(timeTest!)/hiveIpfs_Directory_test3_createDirectory\(timeTest!)")
        }).then({ (directory) -> HivePromise<Bool> in
            return directory.moveTo(newPath: "/")
        }).done({ (re) in
            XCTAssertTrue(re)
            self.lock?.fulfill()
        }).catch({ (err) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

}
