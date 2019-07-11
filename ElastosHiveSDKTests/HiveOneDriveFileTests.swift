

import XCTest
@testable import ElastosHiveSDK

var timeTest: String?
class HiveOneDriveFileTests: XCTestCase {
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

    func testLastUpdatedInfo() {
        //    login
        lock = XCTestExpectation(description: "wait for test login.")
        OneDriveCommon().login(lock!, hiveClient: self.hiveClient!)
        //    create file
        lock = XCTestExpectation(description: "wait for test create file.")
        timeTest = Timestamp.getTimeAtNow()
        OneDriveCommon().createFile(lock!, hiveClient: self.hiveClient!, timeTest!)

        // 1. get an exisiting file lastUpdateInfo
        lock = XCTestExpectation(description: "wait for get an exisiting file lastUpdateInfo.")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveFileHandle> in
                return drive.fileHandle(atPath: "/od_createF_\(timeTest!)")
            }.then{ file -> HivePromise<HiveFileInfo> in
                return file.lastUpdatedInfo()
            }.done{ fileInfo in
                XCTAssertNotNil(fileInfo)
                self.lock?.fulfill()
            }.catch{ error in
                XCTFail()
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)

        // 2. get an non-exisiting file lastUpdateInfo
        lock = XCTestExpectation(description: "wait for get an exisiting file lastUpdateInfo.")
        self.hiveClient?.defaultDriveHandle().then{ drive -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/od_createF_\(timeTest!)_2")
            }.then{ file -> HivePromise<HiveFileInfo> in
                return file.lastUpdatedInfo()
            }.done{ fileInfo in
                XCTFail()
                self.lock?.fulfill()
            }.catch{ error in
                let des = HiveError.des(error as! HiveError)
                XCTAssertEqual(des, "Item does not exist")
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)
    }

    func testCopyTo() {
        //    login
        lock = XCTestExpectation(description: "wait for test login.")
        OneDriveCommon().login(lock!, hiveClient: self.hiveClient!)
        //    create directory
        lock = XCTestExpectation(description: "wait for test create directory.")
        timeTest = Timestamp.getTimeAtNow()
        OneDriveCommon().creatDirectory(lock!, hiveClient: self.hiveClient!, timeTest!)

        // create  a file
        lock = XCTestExpectation(description: "wait for test create file.")
        OneDriveCommon().createFile(lock!, hiveClient: self.hiveClient!, timeTest!)

        //  1. copy to an exisiting directory
        lock = XCTestExpectation(description: "wait for copy to an exisiting directory")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveFileHandle> in
                return drive.fileHandle(atPath: "/od_createF_\(timeTest!)")
            }.then{ file -> HivePromise<Void> in
                return file.copyTo(newPath: "/od_createD_\(timeTest!)")
            }.done{ re in
                self.lock?.fulfill()
            }.catch{ err in
                XCTFail()
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)

        //  2. copy to a non-exisiting directory
        lock = XCTestExpectation(description: "wait for copy to a non-exisiting directory")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveFileHandle> in
                return drive.fileHandle(atPath: "/od_createF_\(timeTest!)")
            }.then{ file -> HivePromise<Void> in
                return file.copyTo(newPath: "/od_createD_\(timeTest!)_non")
            }.done{ re in
                XCTAssertTrue(true)
                self.lock?.fulfill()
            }.catch{ error in
                XCTFail()
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)

        // 3. repeat copy to
        lock = XCTestExpectation(description: "wait for repeat copy to")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveFileHandle> in
                return drive.fileHandle(atPath: "/od_createF_\(timeTest!)")
            }.then{ file -> HivePromise<Void> in
                return file.copyTo(newPath: "/od_createD_\(timeTest!)")
            }.done{ re in
                XCTFail()
                self.lock?.fulfill()
            }.catch{ error in
                let des = HiveError.des(error as! HiveError)
                XCTAssertEqual(des, "Operation failed")
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)
    }

    func testDeleteItem() {
        //    login
        lock = XCTestExpectation(description: "wait for test login.")
        OneDriveCommon().login(lock!, hiveClient: self.hiveClient!)

        // create  a file
        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for test create file.")
        OneDriveCommon().createFile(lock!, hiveClient: self.hiveClient!, timeTest!)

        // 1. delete a exisiting file
        lock = XCTestExpectation(description: "wait for delete a exisiting file")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveFileHandle> in
                return drive.fileHandle(atPath: "/od_createF_\(timeTest!)")
            }.then{ file -> HivePromise<Void> in
                return file.deleteItem()
            }.done{ re in
                self.lock?.fulfill()
            }.catch{ err in
                XCTFail()
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)
    }

    func testMoveTo() {
        //    login
        lock = XCTestExpectation(description: "wait for test login.")
        OneDriveCommon().login(lock!, hiveClient: self.hiveClient!)
        //    create directory
        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for test create directory.")
        OneDriveCommon().creatDirectory(lock!, hiveClient: self.hiveClient!, timeTest!)

        // create  a file
        lock = XCTestExpectation(description: "wait for test create file.")
        OneDriveCommon().createFile(lock!, hiveClient: self.hiveClient!, timeTest!)

        // 1. move to an exisiting directory
        lock = XCTestExpectation(description: "wait for move to an exisiting directory")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveFileHandle> in
                return drive.fileHandle(atPath: "/od_createF_\(timeTest!)")
            }.then{ file -> HivePromise<Void> in
                return file.moveTo(newPath: "/od_createD_\(timeTest!)")
            }.done{ re in
                self.lock?.fulfill()
            }.catch{ err in
                XCTFail()
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)

        // 2. move to a non-exisiting directory
        lock = XCTestExpectation(description: "wait for move to a non-exisiting directory")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveFileHandle> in
                return drive.fileHandle(atPath: "/od_createF_\(timeTest!)")
            }.then{ file -> HivePromise<Void> in
                return file.moveTo(newPath: "/od_createD_\(timeTest!)_non")
            }.done{ re in
                self.lock?.fulfill()
            }.catch{ error in
                let des = HiveError.des(error as! HiveError)
                XCTAssertEqual(des, "Item does not exist")
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)
    }

    func testWriteData() {
        //    login
        lock = XCTestExpectation(description: "wait for test login.")
        OneDriveCommon().login(lock!, hiveClient: self.hiveClient!)

        // create  a file
        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for test create file.")
        OneDriveCommon().createFile(lock!, hiveClient: self.hiveClient!, timeTest!)

        // write
        lock = XCTestExpectation(description: "wait for write.")
        var fl: HiveFileHandle? = nil
        let data1 = "ios test for write \(timeTest!)".data(using: .utf8)
        let data2 = "write data2 \(timeTest!)".data(using: .utf8)
        let le1 = data1?.count
        let le2 = data2?.count

        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveFileHandle> in
                return drive.fileHandle(atPath: "/od_createF_\(timeTest!)")
            }.then{ file -> HivePromise<Int32> in
                fl = file
                return file.writeData(withData: data1!)
            }.then{ length -> HivePromise<Int32> in
                (fl?.writeData(withData: data2!))!
            }
            .then{ length -> HivePromise<Void> in
                return (fl?.commitData())!
            }.then{ void -> HivePromise<Data> in
                return (fl?.readData(le1! + le2!))!
            }.then{ void -> HivePromise<Data> in
                return (fl?.readData(22, 29))!
            }
            .done{ data in
                XCTAssertEqual(data.count,le2!)
                self.lock?.fulfill()
            }.catch{ er in
                XCTFail()
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)
    }

    func testWriteWithPosition() {
        //    login
        lock = XCTestExpectation(description: "wait for test login.")
        OneDriveCommon().login(lock!, hiveClient: self.hiveClient!)

        // create  a file
        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for test create file.")
        OneDriveCommon().createFile(lock!, hiveClient: self.hiveClient!, timeTest!)

        // write
        lock = XCTestExpectation(description: "wait for write.")
        let data1 = "ios test for write \(timeTest!)".data(using: .utf8)
        let data2 = "save 2 ios test for write \(timeTest!)".data(using: .utf8)
        let le1 = data1?.count
        let le2 = data2?.count

        var fl: HiveFileHandle?
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveFileHandle> in
                return drive.fileHandle(atPath: "/od_createF_\(timeTest!)")
            }.then{ file -> HivePromise<Int32> in
                fl = file
                return file.writeData(withData: data1!, 0)
            }.then{ length -> HivePromise<Int32> in
                return fl!.writeData(withData: data2!, 30)
            }.then{ length -> HivePromise<Void> in
                return (fl?.commitData())!
            }.then{ void -> HivePromise<Data> in
                return (fl?.readData(le1! + le2!))!
            }.then{ void -> HivePromise<Data> in
                return (fl?.readData(22, 29))!
            }.done{ data in
                XCTAssertEqual(data.count,22)
                self.lock?.fulfill()
            }.catch{ er in
                XCTFail()
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)
    }

    func testReadData() {
        //    login
        lock = XCTestExpectation(description: "wait for test login.")
        OneDriveCommon().login(lock!, hiveClient: self.hiveClient!)

        // create  a file
        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for test create file.")
        OneDriveCommon().createFile(lock!, hiveClient: self.hiveClient!, timeTest!)

        // write
        lock = XCTestExpectation(description: "wait for test write data.")
        OneDriveCommon().writeData(lock!, hiveClient: self.hiveClient!, timeTest!)

        // read
        let data = "ios test for write \(timeTest!)".data(using: .utf8)
        lock = XCTestExpectation(description: "wait for test read data.")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveFileHandle> in
                return drive.fileHandle(atPath: "/od_createF_\(timeTest!)")
            }.then{ file -> HivePromise<Data> in
                return file.readData(data!.count)
            }.done{ content in
                XCTAssertEqual(content.count, data?.count)
                self.lock?.fulfill()
            }.catch{ error in
                XCTFail()
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)
    }

    func testRead_withPosition() {
        //    login
        lock = XCTestExpectation(description: "wait for test login.")
        OneDriveCommon().login(lock!, hiveClient: self.hiveClient!)

        // create  a file
        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for test create file.")
        OneDriveCommon().createFile(lock!, hiveClient: self.hiveClient!, timeTest!)
        
        // write
        lock = XCTestExpectation(description: "wait for test write data.")
        OneDriveCommon().writeData(lock!, hiveClient: self.hiveClient!, timeTest!)

        // read
        lock = XCTestExpectation(description: "wait for read")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveFileHandle> in
                return drive.fileHandle(atPath: "/od_createF_\(timeTest!)")
            }.then{ file -> HivePromise<Data> in
                return file.readData(10, 0)
            }.done{ content in
                XCTAssertEqual(content.count, 10)
                self.lock?.fulfill()
            }.catch{ error in
                XCTFail()
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)
    }
}
