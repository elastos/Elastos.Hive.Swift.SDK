

import XCTest
@testable import ElastosHiveSDK

class HiveIpfsFileTests: XCTestCase, Authenticator{
    func requestAuthentication(_ requestURL: String) -> Bool {
        return true
    }
    var hiveClient: HiveClientHandle?
    var hiveParams: DriveParameter?
    var lock: XCTestExpectation?
    let timeout: Double = 600.0

    override func setUp() {
        hiveParams = DriveParameter.createForIpfsDrive("uid-6516f0c7-d5bb-431a-9f12-1f8d8e923642")
        HiveClientHandle.createInstance(hiveParams!)
        hiveClient = HiveClientHandle.sharedInstance(type: .hiveIPFS)
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

    func testB_creatFile() {

        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for test2_creatFile")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.createFile(withPath: "/Ipfs_testB_creatFile_\(timeTest!)")
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

        lock = XCTestExpectation(description: "wait for test3_lastUpdatedInfo")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/Ipfs_testB_creatFile_\(timeTest!)")
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
            return drive.fileHandle(atPath: "/Ipfs_testB_creatFile_\(timeTest!)")
        }).then({ (file) -> HivePromise<HiveVoid> in
            return file.copyTo(newPath: "/\(timeTest!)/Ipfs_testB_creatFile_\(timeTest!)")
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
        lock = XCTestExpectation(description: "wait for test5_deleteItem")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/Ipfs_testB_creatFile_\(timeTest!)")
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
        lock = XCTestExpectation(description: "wait for test6_moveTo")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/\(timeTest!)/Ipfs_testB_creatFile_\(timeTest!)")
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
        let data = "ios test for ipfs write \(timeTest!)".data(using: .utf8)
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/Ipfs_testB_creatFile_\(timeTest!)")
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
        lock = XCTestExpectation(description: "wait for testH_readData")
        let data = "ios test for ipfs write \(timeTest!)".data(using: .utf8)
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/Ipfs_testB_creatFile_\(timeTest!)")
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
        lock = XCTestExpectation(description: "wait for testI_read_withPosition")
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/Ipfs_testB_creatFile_\(timeTest!)")
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
        lock = XCTestExpectation(description: "wait for testJ_write_withPosition")
        let data = "ios test for write \(timeTest!)".data(using: .utf8)
        let data2 = "save 2 ios test for write \(timeTest!)".data(using: .utf8)

        var fl: HiveFileHandle?
        self.hiveClient?.defaultDriveHandle().then({ (drive) -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/Ipfs_testB_creatFile_\(timeTest!)")
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
