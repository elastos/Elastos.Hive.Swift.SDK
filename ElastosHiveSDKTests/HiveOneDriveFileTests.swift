

import XCTest
@testable import ElastosHiveSDK

var timeTest: String?
class HiveOneDriveFileTests: XCTestCase,Authenticator {
    func requestAuthentication(_ requestURL: String) -> Bool {
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

    func test2_creatFile() {

        timeTest = HelperMethods.getCurrentTime()
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

    func test3_lastUpdatedInfo() {

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

    func test4_copyTo() {

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
        }).then({ (file) -> HivePromise<Bool> in
            return file.copyTo(newPath: "/\(timeTest!)")
        }).done({ (re) in
            XCTAssertTrue(re)
            self.lock?.fulfill()
        }).catch({ (err) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test5_deleteItem() {
        // delete
        lock = XCTestExpectation(description: "wait for test4_deleteItem")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/test_file_\(timeTest!)")
        }).then({ (file) -> HivePromise<Bool> in
            return file.deleteItem()
        }).done({ (re) in
            XCTAssertTrue(re)
            self.lock?.fulfill()
        }).catch({ (err) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test6_moveTo() {
        // move
        lock = XCTestExpectation(description: "wait for test4_moveTo")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/\(timeTest!)/test_file_\(timeTest!)")
        }).then({ (file) -> HivePromise<Bool> in
            return file.moveTo(newPath: "/")
        }).done({ (re) in
            XCTAssertTrue(re)
            self.lock?.fulfill()
        }).catch({ (err) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test7_writeData() {

        lock = XCTestExpectation(description: "wait for test5_writeData")
        let data = "ios test for write \(timeTest!)".data(using: .utf8)
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/test_file_\(timeTest!)")
        }).then({ (file) -> HivePromise<Bool> in
            return file.writeData(withData: data!)
        }).done({ (re) in
            XCTAssertTrue(re)
            self.lock?.fulfill()
        }).catch({ (er) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test8_readData() {
        lock = XCTestExpectation(description: "wait for test5_readData")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/test_file_\(timeTest!)")
        }).then({ (file) -> HivePromise<String> in
            return file.readData()
        }).done({ (content) in
            XCTAssertEqual(content, "ios test for write \(timeTest!)")
            self.lock?.fulfill()
        }).catch({ (er) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test9_writeDataLagre() {

        timeTest = HelperMethods.getCurrentTime()
        lock = XCTestExpectation(description: "wait for test5_writeData")
        let urlPath = "/Users/liaihong/Desktop/DSC_0788.JPG"
        let url = URL(fileURLWithPath: urlPath)
        var data = Data()
        do {
            data = try Data.init(contentsOf: url)
        } catch {
            print(error)
        }
        print(data)
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.createFile(withPath: "/test_file_\(timeTest!)_large")
        }).then({ (file) -> HivePromise<Bool> in
            return file.writeDataWithLarge(withPath: urlPath)
        }).done({ (re) in
            XCTAssertTrue(re)
            self.lock?.fulfill()
        }).catch({ (er) in
            XCTFail()
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

}
