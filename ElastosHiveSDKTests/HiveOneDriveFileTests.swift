

import XCTest
@testable import ElastosHiveSDK

var timeTest: String?
class HiveOneDriveFileTests: XCTestCase,Authenticator {
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
    let timeout: Double = 6000.0

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
                try self.hiveClient?.login(self as Authenticator)
                self.lock?.fulfill()
            }catch {
                XCTFail()
                self.lock?.fulfill()
            }
        }
        wait(for: [lock!], timeout: timeout)
    }

    func testB_creatFile() {

        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for test2_creatFile")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.createFile(withPath: "/test_file_\(timeTest!)")
        }).done({ (file) in
            XCTAssertNotNil(file)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func testC_lastUpdatedInfo() {

        lock = XCTestExpectation(description: "wait for test2_creatFile")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/test_file_\(timeTest!)")
        }).then({ (file) -> HivePromise<HiveFileInfo> in
            return file.lastUpdatedInfo()
        }).done({ (fileInfo) in
            XCTAssertNotNil(fileInfo)
            self.lock?.fulfill()
        }).catch({ (error) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func testD_copyTo() {

        // copy
        lock = XCTestExpectation(description: "wait for test4_preCreate")
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

        lock = XCTestExpectation(description: "wait for test4_copyTo")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/test_file_\(timeTest!)")
        }).then({ (file) -> HivePromise<HiveVoid> in
            return file.copyTo(newPath: "/\(timeTest!)")
        }).done({ (re) in
            self.lock?.fulfill()
        }).catch({ (err) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func testE_deleteItem() {
        // delete
        lock = XCTestExpectation(description: "wait for test4_deleteItem")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/test_file_\(timeTest!)")
        }).then({ (file) -> HivePromise<HiveVoid> in
            return file.deleteItem()
        }).done({ (re) in
            self.lock?.fulfill()
        }).catch({ (err) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func testF_moveTo() {
        // move
        lock = XCTestExpectation(description: "wait for test4_moveTo")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/\(timeTest!)/test_file_\(timeTest!)")
        }).then({ (file) -> HivePromise<HiveVoid> in
            return file.moveTo(newPath: "/")
        }).done({ (re) in
            self.lock?.fulfill()
        }).catch({ (err) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func testG_writeData() {

        lock = XCTestExpectation(description: "wait for test5_writeData")
        var fl: HiveFileHandle? = nil
        let data = "ios test for write \(timeTest!)".data(using: .utf8)
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/test_file_\(timeTest!)")
        }).then({ (file) -> HivePromise<Int32> in
            fl = file
            return file.writeData(withData: data!)
        }).then({ (length) -> HivePromise<HiveVoid> in
            return (fl?.commitData())!
        }).done({ (re) in
            self.lock?.fulfill()
        }).catch({ (er) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func testH_readData() {
        lock = XCTestExpectation(description: "wait for test5_readData")
        let data = "ios test for write \(timeTest!)".data(using: .utf8)
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/test_file_\(timeTest!)")
        }).then({ (file) -> HivePromise<Data> in
            return file.readData(data!.count)
        }).done({ (content) in
            XCTAssertEqual(content.count, data?.count)
            self.lock?.fulfill()
        }).catch({ (er) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }


    func testI_read_withPosition() {
        lock = XCTestExpectation(description: "wait for testI_read_tobuffer")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/test_file_\(timeTest!)")
        }).then({ (file) -> HivePromise<Data> in
            return file.readData(10, 0)
        }).done({ (content) in
            XCTAssertEqual(content.count, 10)
            self.lock?.fulfill()
        }).catch({ (er) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func testJ_write_withPosition() {
        lock = XCTestExpectation(description: "wait for testJ_write_tobuffer")
        let data = "ios test for write \(timeTest!)".data(using: .utf8)
        let data2 = "save 2 ios test for write \(timeTest!)".data(using: .utf8)

        var fl: HiveFileHandle?
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/test_file_\(timeTest!)")
        }).then({ (file) -> HivePromise<Int32> in
            fl = file
            return file.writeData(withData: data!, 0)
        }).then({ (length) -> HivePromise<Int32> in
            return fl!.writeData(withData: data2!, 30)
        }).then({ (l) -> HivePromise<HiveVoid> in
            return (fl?.commitData())!
        }).done({ (re) in
            print(re)
            self.lock?.fulfill()
        }).catch({ (er) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }


}
