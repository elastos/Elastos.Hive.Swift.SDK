

import XCTest
@testable import ElastosHiveSDK

class HiveOneDriveDirectoryTests: XCTestCase,Authenticator {

    func requestAuthentication(_ requestURL: String) -> Bool {
        return true
    }
    var hiveClient: HiveClientHandle?
    var hiveParam: DriveParameter?
    var lock: XCTestExpectation?
    let timeout: Double = 600.0

    override func setUp() {

        hiveParam = DriveParameter.createForOneDrive("31c2dacc-80e0-47e1-afac-faac093a739c", "Files.ReadWrite%20offline_access", REDIRECT_URI)
        HiveClientHandle.createInstance(hiveParam!)
        hiveClient = HiveClientHandle.sharedInstance(type: .oneDrive)
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

    func test3_createDirectory() {

        timeTest = HelperMethods.getCurrentTime()
        lock = XCTestExpectation(description: "wait for test3_createDirectory")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDirectoryHandle> in
            return drive.rootDirectoryHandle()
        }).then({ (directory) -> HivePromise<HiveDirectoryHandle> in
            return directory.createDirectory(withPath: "测试\(timeTest!)")
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
            return directory.directoryHandle(atPath: "测试\(timeTest!)")
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
            directory.createFile(withPath: "creat_file\(timeTest!)")
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
            return directory.fileHandle(atPath: "creat_file\(timeTest!)")
        }).done({ (file) in
            XCTAssertNotNil(file)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test7_copyTo_moveTo_deleteItem() {

        // copy
        lock = XCTestExpectation(description: "wait for test7_copyTo_moveTo_deleteItem")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDirectoryHandle> in
            return drive.createDirectory(withPath: "\(timeTest!)")
        }).done({ (re) in
            XCTAssertNotNil(re)
            self.lock?.fulfill()
        }).catch({ (err) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)

        lock = XCTestExpectation(description: "wait for test4_copyTo")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDirectoryHandle> in
            return drive.directoryHandle(atPath: "测试\(timeTest!)")
        }).then({ (directory) -> HivePromise<Bool> in
            return directory.copyTo(newPath: "/\(timeTest!)")
        }).done({ (re) in
            XCTAssertTrue(re)
            self.lock?.fulfill()
        }).catch({ (err) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)

        // delete
        lock = XCTestExpectation(description: "wait for test4_deleteItem")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDirectoryHandle> in
            return drive.directoryHandle(atPath: "测试\(timeTest!)")
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

        // move
        lock = XCTestExpectation(description: "wait for test4_moveTo")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDirectoryHandle> in
            return drive.directoryHandle(atPath: "/\(timeTest!)/测试\(timeTest!)")
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
