

import XCTest
@testable import ElastosHiveSDK

class HiveOneDriveDirectoryTests: XCTestCase,Authenticator {

    func requestAuthentication(_ requestURL: String) -> Bool {
        let scops = ["Files.ReadWrite","offline_access"]
        let scopStr = scops.joined(separator: " ")
        let authViewController: AuthWebViewController = AuthWebViewController()
        DispatchQueue.main.sync {
            let rootViewController = UIApplication.shared.keyWindow?.rootViewController
            rootViewController!.present(authViewController, animated: true, completion: nil)
            authViewController.loadRequest("31c2dacc-80e0-47e1-afac-faac093a739c", REDIRECT_URI, "code", scopStr)
        }
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

    func testA_Login() {
        lock = XCTestExpectation(description: "wait for test1_Login")

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
        wait(for: [lock!], timeout: timeout)
    }

    func testB_lastUpdatedInfo() {
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

    func testC_createDirectory() {

        timeTest = ConvertHelper.getCurrentTime()
        lock = XCTestExpectation(description: "wait for test3_createDirectory")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDirectoryHandle> in
            return drive.rootDirectoryHandle()
        }).then({ (directory) -> HivePromise<HiveDirectoryHandle> in
            return directory.createDirectory(withName: "测试\(timeTest!)")
        }).done({ (directory) in
            XCTAssertNotNil(directory)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func testD_directoryHandle() {

        lock = XCTestExpectation(description: "wait for test4_directoryHandle")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDirectoryHandle> in
            return drive.rootDirectoryHandle()
        }).then({ (directory) -> HivePromise<HiveDirectoryHandle> in
            return directory.directoryHandle(atName: "测试\(timeTest!)")
        }).done({ (directory) in
            XCTAssertNotNil(directory)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func testE_createFile() {
        lock = XCTestExpectation(description: "wait for test5_createFile")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDirectoryHandle> in
            return drive.rootDirectoryHandle()
        }).then({ (directory) -> HivePromise<HiveFileHandle> in
            directory.createFile(withName: "creat_file\(timeTest!)")
        }).done({ (file) in
            XCTAssertNotNil(file)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func testF_fileHandle() {

        lock = XCTestExpectation(description: "wait for test6_fileHandle")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDirectoryHandle> in
            return drive.rootDirectoryHandle()
        }).then({ (directory) -> HivePromise<HiveFileHandle> in
            return directory.fileHandle(atName: "creat_file\(timeTest!)")
        }).done({ (file) in
            XCTAssertNotNil(file)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }
    func testG_getChildren() {
        lock = XCTestExpectation(description: "wait for test7_getChildren")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveDirectoryHandle> in
            return drive.rootDirectoryHandle()
        }).then({ (directory) -> HivePromise<HiveDirectoryHandle> in
            return directory.directoryHandle(atName: "测试\(timeTest!)")
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

    func testH_getChildren() {
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

    func testI_copyTo() {

        lock = XCTestExpectation(description: "wait for test8_copyTo")
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

        lock = XCTestExpectation(description: "wait for test8_copyTo")
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
    }

    func testJ_deleteItem() {

        lock = XCTestExpectation(description: "wait for test9_deleteItem")
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
    }

    func testK_moveTo() {

        lock = XCTestExpectation(description: "wait for test10_moveTo")
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
