

import XCTest
@testable import ElastosHiveSDK


class HiveOneDriveClient: XCTestCase,Authenticator {

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

    func test2_lastUpdatedInfo() {
        lock = XCTestExpectation(description: "wait for test2_lastUpdatedInfo")
        self.hiveClient?.lastUpdatedInfo().done({ (clientInfo) in
            XCTAssertNotNil(clientInfo)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test3_defaultDriveHandle() {
        lock = XCTestExpectation(description: "wait for test3_defaultDriveHandle")
        self.hiveClient?.defaultDriveHandle().done({ (drive) in
            XCTAssertNotNil(drive)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test4_logout() {
        lock = XCTestExpectation(description: "wait for test4_logout")
        let globalQueue = DispatchQueue.global()
        globalQueue.async {
            let result = self.hiveClient?.logout()
            XCTAssertTrue(result!)
            self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)
    }

}
