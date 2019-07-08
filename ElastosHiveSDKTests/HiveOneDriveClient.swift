

import XCTest
@testable import ElastosHiveSDK


class HiveOneDriveClient: XCTestCase {

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

    func testLogin() {
        // 1. Test nonarm login
        lock = XCTestExpectation(description: "wait for test nonarm login.")
        OneDriveCommon().login(lock!, hiveClient: self.hiveClient!)

        // 2. Test repeat login
        lock = XCTestExpectation(description: "wait for test repeat login.")
        OneDriveCommon().login(lock!, hiveClient: self.hiveClient!)
    }

    func testLastUpdatedInfo() {
        // 1. Test lastUdateInfo after login
        lock = XCTestExpectation(description: "wait for test login.")
        //    anyway login
        OneDriveCommon().login(lock!, hiveClient: self.hiveClient!)
        lock = XCTestExpectation(description: "wait for test lastUpateInfo after login.")
        self.hiveClient?.lastUpdatedInfo()
            .done{ clientInfo in
                XCTAssertNotNil(clientInfo)
                self.lock?.fulfill()
            }
            .catch{ error in
                XCTFail()
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)

        // 2. Test lastUdateInfo after logout
        lock = XCTestExpectation(description: "wait for test logout.")
        // logout
        OneDriveCommon().logOut(lock!, hiveClient: self.hiveClient!)

        lock = XCTestExpectation(description: "wait for test lastUdateInfo after logout.")
        self.hiveClient?.lastUpdatedInfo()
            .done{ clientInfo in
                XCTFail()
                self.lock?.fulfill()
            }
            .catch{ error in
                let des = HiveError.des(error as! HiveError)
                XCTAssertEqual(des, "Please login first")
                self.lock?.fulfill()
        }
    }

    func testDefaultDriveHandle() {

        // 1. Test defaultDriveHandle after login
        lock = XCTestExpectation(description: "wait for test login.")
        //    anyway login
        OneDriveCommon().login(lock!, hiveClient: self.hiveClient!)

        lock = XCTestExpectation(description: "wait for test defaultDriveHandle after login.")
        self.hiveClient?.defaultDriveHandle()
            .done{ drive in
                XCTAssertNotNil(drive)
                self.lock?.fulfill()
            }
            .catch{ error in
                XCTFail()
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)

        // 2. Test defaultDriveHandle after logout
        lock = XCTestExpectation(description: "wait for test logout.")
        // logout
        OneDriveCommon().logOut(lock!, hiveClient: self.hiveClient!)

        lock = XCTestExpectation(description: "wait for test defaultDriveHandle after logout.")
        self.hiveClient?.defaultDriveHandle()
            .done{ clientInfo in
                XCTFail()
                self.lock?.fulfill()
            }
            .catch{ error in
                let des = HiveError.des(error as! HiveError)
                XCTAssertEqual(des, "Please login first")
                self.lock?.fulfill()
        }
    }

    func testLogout() {
        // 1. Test nonarm logout
        lock = XCTestExpectation(description: "wait for test nonarm login.")
        OneDriveCommon().login(lock!, hiveClient: self.hiveClient!)
        lock = XCTestExpectation(description: "wait for test nonarm logout.")
        OneDriveCommon().logOut(lock!, hiveClient: self.hiveClient!)

        // 2. Test without login
        lock = XCTestExpectation(description: "wait for test without login.")
        OneDriveCommon().logOut(lock!, hiveClient: self.hiveClient!)
    }

}
