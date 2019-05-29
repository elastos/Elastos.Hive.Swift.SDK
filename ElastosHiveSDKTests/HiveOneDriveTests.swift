

import XCTest
@testable import ElastosHiveSDK

let REDIRECT_URI: String = "http://localhost:44316"
class HiveOneDriveTests: XCTestCase,Authenticator {
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
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDriveInfo> in
            return drive.lastUpdatedInfo()
        }).done({ (driveInfo) in
            XCTAssertNotNil(driveInfo)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test3_RootDirectoryHandle() {

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
        wait(for: [lock!], timeout: timeout)
    }

    func test4_CreateDirectory() {

        lock = XCTestExpectation(description: "wait for test4_CreateDirectory")
        timeTest = HelperMethods.getCurrentTime()
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDirectoryHandle> in
            return drive.createDirectory(withPath: "/test_ios_folder_\(timeTest!)")
        }).done({ (directory) in
            XCTAssertNotNil(directory)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test5_directoryHandle() {
        lock = XCTestExpectation(description: "wait for test5_directoryHandle")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDirectoryHandle> in
            return drive.directoryHandle(atPath: "/test_ios_folder_\(timeTest!)")
        }).done({ (directory) in
            XCTAssertNotNil(directory)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test6_createFile() {
        timeTest = HelperMethods.getCurrentTime()
        lock = XCTestExpectation(description: "wait for test6_createFile")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.createFile(withPath: "/test_ios_file_\(timeTest!)")
        }).done({ (file) in
            XCTAssertNotNil(file)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test7_GetFileHandle() {

        lock = XCTestExpectation(description: "wait for test7_GetFileHandle")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/test_ios_file_\(timeTest!)")
        }).done({ (file) in
            XCTAssertNotNil(file)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
