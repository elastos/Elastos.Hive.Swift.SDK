

import XCTest
@testable import ElastosHiveSDK

let REDIRECT_URI: String = "http://localhost:44316"
class HiveOneDriveTests: XCTestCase {

    var hiveDrive: HiveDriveHandle? = nil
    var hiveParam: DriveParameters? = nil
    var lock: XCTestExpectation?
    let timeout: Double = 600.0

    override func setUp() {

        hiveParam = DriveParameters.createForOneDrive(applicationId: "31c2dacc-80e0-47e1-afac-faac093a739c", scopes: ["Files.ReadWrite","offline_access"], redirectUrl: REDIRECT_URI)
        HiveDriveHandle.createInstance(hiveParam!)
        hiveDrive = HiveDriveHandle.sharedInstance(type: .oneDrive)
    }

    override func tearDown() {
        hiveParam = nil
        hiveDrive = nil
    }

    func test1_Login() {
        lock = XCTestExpectation(description: "wait for hiveDrive call login callback")
        hiveDrive?.login(withResult: { (result, error) in
            self.lock?.fulfill()
            XCTAssertTrue(result!, error.debugDescription)
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test2_RootDirectoryHandle() {

        lock = XCTestExpectation(description: "wait for hiveDrive call rootDirectoryHandle callback")
        try? hiveDrive?.rootDirectoryHandle(withResult: { (hiveFile, error) in
            self.lock?.fulfill()
            XCTAssertNotNil(hiveFile, error.debugDescription)
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test3_CreateDirectory() {

        lock = XCTestExpectation(description: "wait for getFileHandle callback")
        try? hiveDrive?.getFileHandle(atPath: "test1/test.txt", withResult: { (hiveFile, error) in
            if hiveFile != nil {
                XCTAssertEqual("test.txt", hiveFile!.name)
                try? hiveFile?.deleteItem(withResult: { (re, error) in
                    XCTAssertTrue(re!, error.debugDescription)
                    self.lock?.fulfill()
                })
            }else{
                self.lock?.fulfill()
            }
        })
        wait(for: [lock!], timeout: timeout)

        lock = XCTestExpectation(description: "wait for hiveDrive call createFile callback")
        try? hiveDrive?.createFile(atPath: "test1/test.txt", withResult: { (hiveFile, error) in
            self.lock?.fulfill()
            XCTAssertNotNil(hiveFile, error.debugDescription)
            if hiveFile != nil {
                XCTAssertEqual("test.txt", hiveFile!.name)
            }
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test4_GetFileHandle() {

        lock = XCTestExpectation(description: "wait for getFileHandle callback")
        try? hiveDrive?.getFileHandle(atPath: "test1/test.txt", withResult: { (hiveFile, error) in
            self.lock?.fulfill()
            XCTAssertNotNil(hiveFile, error.debugDescription)
        })
        wait(for: [lock!], timeout: timeout)

        lock = XCTestExpectation(description: "wait for getFileHandle callback for get a nil file")
        try? hiveDrive?.getFileHandle(atPath: "test1/some.txt", withResult: { (hiveFile, er) in
            self.lock?.fulfill()
            XCTAssertNil(hiveFile, er.debugDescription)
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test5_Logout() {
        lock = XCTestExpectation(description: "wait for hiveDrive call logout callback")
        hiveDrive?.logout(withResult: { (re, er) in
            self.lock?.fulfill()
            XCTAssertTrue(re!, er.debugDescription)
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
