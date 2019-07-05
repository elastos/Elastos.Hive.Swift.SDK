

import XCTest
@testable import ElastosHiveSDK

class HiveOneDriveDirectoryTests: XCTestCase {

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

    func testLastUpdatedInfo() {
        //    login
        lock = XCTestExpectation(description: "wait for test login.")
        OneDriveCommon().login(lock!, hiveClient: self.hiveClient!)

        // 1. get an exisiting file lastUpdateInfo
        lock = XCTestExpectation(description: "get an exisiting file lastUpdateInfo")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }.then{ directory -> HivePromise<HiveDirectoryInfo> in
                return directory.lastUpdatedInfo()
            }.done{ directoryInfo in
                XCTAssertNotNil(directoryInfo)
                self.lock?.fulfill()
            }.catch{ error in
                XCTFail()
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)
    }

    func testCreateDirectory() {
        //    login
        lock = XCTestExpectation(description: "wait for test login.")
        OneDriveCommon().login(lock!, hiveClient: self.hiveClient!)

        // 1. nonarm create
        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for nonarm create")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }.then{ directory -> HivePromise<HiveDirectoryHandle> in
                return directory.createDirectory(withName: "od_createD_\(timeTest!)")
            }.done{ directory in
                XCTAssertNotNil(directory.directoryId)
                self.lock?.fulfill()
            }.catch{ error in
                XCTFail()
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)

        // 2. create same name directory
        lock = XCTestExpectation(description: "wait for create same name directory")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }.then{ directory -> HivePromise<HiveDirectoryHandle> in
                return directory.createDirectory(withName: "od_createD_\(timeTest!)")
            }.done{ directory in
                XCTFail()
                self.lock?.fulfill()
            }.catch{ error in
                let des = HiveError.des(error as! HiveError)
                XCTAssertEqual(des, "An item with the same name already exists under the parent")
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)
    }

    func testDirectoryHandle() {
        //    login
        lock = XCTestExpectation(description: "wait for test login.")
        OneDriveCommon().login(lock!, hiveClient: self.hiveClient!)
        //   create directory
        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for test create directory.")
        OneDriveCommon().creatDirectoryWithName(lock!, hiveClient: self.hiveClient!, timeTest!)

        //   1. get existing path directory
        lock = XCTestExpectation(description: "wait for get existing path directory.")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }.then{ directory -> HivePromise<HiveDirectoryHandle> in
                return directory.directoryHandle(atName: "od_createD_\(timeTest!)")
            }.done{ directory in
                XCTAssertNotNil(directory.directoryId)
                self.lock?.fulfill()
            }.catch{ error in
                XCTFail()
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)

        // 2. get non-existing path directory
        lock = XCTestExpectation(description: "wait for get non-existing path directory.")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }.then{ directory -> HivePromise<HiveDirectoryHandle> in
                return directory.directoryHandle(atName: "od_createD_\(timeTest!)_2")
            }.done{ directory in
                XCTFail()
                self.lock?.fulfill()
            }.catch{ error in
                let des = HiveError.des(error as! HiveError)
                XCTAssertEqual(des, "Item does not exist")
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)
    }

    func testCreateFile() {
        //    login
        lock = XCTestExpectation(description: "wait for test login.")
        OneDriveCommon().login(lock!, hiveClient: self.hiveClient!)
        // 1. create nanorm file
        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for create nanorm file")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }.then{ directory -> HivePromise<HiveFileHandle> in
                directory.createFile(withName: "od_createF_\(timeTest!)")
            }.done{ file in
                XCTAssertNotNil(file)
                self.lock?.fulfill()
            }.catch{ error in
                XCTFail()
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)

        // 2. create repleate file
        lock = XCTestExpectation(description: "wait for create repleate file")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }.then{ directory -> HivePromise<HiveFileHandle> in
                directory.createFile(withName: "od_createF_\(timeTest!)")
            }.done{ file in
                XCTFail()
                self.lock?.fulfill()
            }.catch{ error in
                let des = HiveError.des(error as! HiveError)
                XCTAssertEqual(des, "An item with the same name already exists under the parent")
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)
    }

    func testFileHandle() {
        //    login
        lock = XCTestExpectation(description: "wait for test login.")
        OneDriveCommon().login(lock!, hiveClient: self.hiveClient!)

        // create file
        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for create file.")
        OneDriveCommon().createFileWithName(lock!, hiveClient: self.hiveClient!, timeTest!)

        // 1. get existing path file
        lock = XCTestExpectation(description: "wait for get existing path file")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }.then{ directory -> HivePromise<HiveFileHandle> in
                return directory.fileHandle(atName: "od_createF_\(timeTest!)")
            }.done{ file in
                XCTAssertNotNil(file)
                self.lock?.fulfill()
            }.catch{ error in
                XCTFail()
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)

        // 2. get non-existing path file
        lock = XCTestExpectation(description: "wait for get non-existing path file")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }.then{ directory -> HivePromise<HiveFileHandle> in
                return directory.fileHandle(atName: "od_createF_\(timeTest!)_2")
            }.done{ file in
                XCTFail()
                self.lock?.fulfill()
            }.catch{ error in
                let des = HiveError.des(error as! HiveError)
                XCTAssertEqual(des, "Item does not exist")
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)
    }

    func testGetChildren() {
        //    login
        lock = XCTestExpectation(description: "wait for test login.")
        OneDriveCommon().login(lock!, hiveClient: self.hiveClient!)

        //  1. get root children
        lock = XCTestExpectation(description: "wait for get root children")
        self.hiveClient?.defaultDriveHandle()
            .then{ (drive) -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }.then{ directory -> HivePromise<HiveChildren> in
                return directory.getChildren()
            }.done{ children in
                XCTAssertNotNil(children)
                self.lock?.fulfill()
            }.catch{ error in
                XCTFail()
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)
    }

    func testCopyTo() {
        //    login
        lock = XCTestExpectation(description: "wait for test login.")
        OneDriveCommon().login(lock!, hiveClient: self.hiveClient!)
        //   create directory
        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for test create directory.")
        OneDriveCommon().creatDirectoryWithName(lock!, hiveClient: self.hiveClient!, timeTest!)
        //   create directory 2
        lock = XCTestExpectation(description: "wait for test create directory.")
        OneDriveCommon().creatDirectoryWithName(lock!, hiveClient: self.hiveClient!, (timeTest! + "_2"))

        // 1. copy to an exisiting directory
        lock = XCTestExpectation(description: "wait for copy to an exisiting directory")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }.then{ directory -> HivePromise<HiveDirectoryHandle> in
                return directory.directoryHandle(atName: "od_createD_\(timeTest!)")
            }.then{ directory -> HivePromise<HiveVoid> in
                return directory.copyTo(newPath: "/od_createF_\(timeTest! + "_2")")
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
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }.then{ directory -> HivePromise<HiveDirectoryHandle> in
                return directory.directoryHandle(atName: "od_createD_\(timeTest!)")
            }.then{ directory -> HivePromise<HiveVoid> in
                return directory.copyTo(newPath: "/od_createF_\(timeTest!)")
            }.done{ re in
                self.lock?.fulfill()
            }.catch{ err in
                XCTFail()
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)

        // 3. repeat copy to
        lock = XCTestExpectation(description: "wait for repeat copy to")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }.then{ directory -> HivePromise<HiveDirectoryHandle> in
                return directory.directoryHandle(atName: "od_createD_\(timeTest!)")
            }.then{ directory -> HivePromise<HiveVoid> in
                return directory.copyTo(newPath: "/od_createF_\(timeTest! + "_2")")
            }.done{ re in
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
        //   create directory
        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for test create directory.")
        OneDriveCommon().creatDirectoryWithName(lock!, hiveClient: self.hiveClient!, timeTest!)

        // 1. delete a exisiting directory
        lock = XCTestExpectation(description: "wait for delete a exisiting directory")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }.then{ directory -> HivePromise<HiveDirectoryHandle> in
                return directory.directoryHandle(atName: "od_createD_\(timeTest!)")
            }.then{ directory -> HivePromise<HiveVoid> in
                return directory.deleteItem()
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
        //   create directory
        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for test create directory.")
        OneDriveCommon().creatDirectoryWithName(lock!, hiveClient: self.hiveClient!, timeTest!)
        //   create directory 2
        lock = XCTestExpectation(description: "wait for test create directory.")
        OneDriveCommon().creatDirectoryWithName(lock!, hiveClient: self.hiveClient!, (timeTest! + "_2"))

        //   1. move to an exisiting directory
        lock = XCTestExpectation(description: "wait for move to an exisiting directory")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }.then{ directory -> HivePromise<HiveDirectoryHandle> in
                return directory.directoryHandle(atName: "/od_createD_\(timeTest!)")
            }.then{ directory -> HivePromise<HiveVoid> in
                return directory.moveTo(newPath: "/od_createD_\(timeTest! + "_2")")
            }.done{ re in
                self.lock?.fulfill()
            }.catch{ err in
                XCTFail()
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)

        //   1. move to an non-exisiting directory
        lock = XCTestExpectation(description: "wait for move to an non-exisiting directory")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }.then{ directory -> HivePromise<HiveDirectoryHandle> in
                return directory.directoryHandle(atName: "/od_createD_\(timeTest! + "_2")/od_createD_\(timeTest!)")
            }.then{ directory -> HivePromise<HiveVoid> in
                return directory.moveTo(newPath: "/\(timeTest! + "_2")")
            }.done{ re in
                self.lock?.fulfill()
            }.catch{ err in
                XCTFail()
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)
    }
}
