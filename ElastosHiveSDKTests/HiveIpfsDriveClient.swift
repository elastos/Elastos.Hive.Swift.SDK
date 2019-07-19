
import XCTest
@testable import ElastosHiveSDK

class HiveIpfsDriveClient: XCTestCase {
    var hiveClient: HiveClientHandle?
    var hiveParams: DriveParameter?
    var lock: XCTestExpectation?
    var timeout: Double = 600.0

    override func setUp() {
        let rpcAddrs = IPFSEntry("uid-6516f0c7-d5bb-431a-9f12-1f8d8e923642", addrs)
        hiveParams = DriveParameter.createForIpfsDrive(rpcAddrs)
        HiveClientHandle.createInstance(hiveParams!)
        hiveClient = HiveClientHandle.sharedInstance(type: .hiveIPFS)
    }

    func testLogin() {
        // 1. Test nonarm login
        lock = XCTestExpectation(description: "wait for test nonarm login.")
        IpfsCommon().login(lock!, hiveClient: self.hiveClient!)

        // 2. Test repeat login
        lock = XCTestExpectation(description: "wait for test repeat login.")
        IpfsCommon().login(lock!, hiveClient: self.hiveClient!)
    }

    func testLastUpdatedInfo() {
        // 1. Test lastUdateInfo after login
        lock = XCTestExpectation(description: "wait for test login.")
        //    anyway login
        IpfsCommon().login(lock!, hiveClient: self.hiveClient!)
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
        IpfsCommon().logOut(lock!, hiveClient: self.hiveClient!)

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
        IpfsCommon().login(lock!, hiveClient: self.hiveClient!)

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
        IpfsCommon().logOut(lock!, hiveClient: self.hiveClient!)

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
        IpfsCommon().login(lock!, hiveClient: self.hiveClient!)
        lock = XCTestExpectation(description: "wait for test nonarm logout.")
        IpfsCommon().logOut(lock!, hiveClient: self.hiveClient!)

        // 2. Test without login
        lock = XCTestExpectation(description: "wait for test without login.")
        IpfsCommon().logOut(lock!, hiveClient: self.hiveClient!)
    }
    
}
