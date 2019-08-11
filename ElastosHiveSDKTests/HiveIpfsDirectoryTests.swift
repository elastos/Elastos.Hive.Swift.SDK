

import XCTest
@testable import ElastosHiveSDK

class HiveIpfsDirectoryTests: XCTestCase {

    var hiveClient: HiveClientHandle?
    var hiveParams: DriveParameter?
    let rpcAddrs: IPFSEntry = IPFSEntry("uid-283744b9-57e7-4af7-b5b0-7957f80c6349", addrs)
    let store: String = "\(NSHomeDirectory())/Library/Caches/ipfs"
    var lock: XCTestExpectation?
    var timeout: Double = 600.0

    override func setUp() {
        hiveParams = IPFSParameter(rpcAddrs,store)
        HiveClientHandle.createInstance(hiveParams!)
        hiveClient = HiveClientHandle.sharedInstance(type: .hiveIPFS)
    }

    override func tearDown() {
    }

    func testLastUpdatedInfo() {
        //    login
        lock = XCTestExpectation(description: "wait for test login.")
        IpfsCommon().login(lock!, hiveClient: self.hiveClient!)

        // 1. get an exisiting file lastUpdateInfo
        lock = XCTestExpectation(description: "get an exisiting file lastUpdateInfo")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }.then{ directory -> HivePromise<HiveDirectoryInfo> in
                return directory.lastUpdatedInfo()
            }.done{ directoryInfo in
                XCTAssertNotNil(directoryInfo.getValue(HiveDirectoryInfo.itemId))
                XCTAssertNotNil(directoryInfo.getValue(HiveDirectoryInfo.name))
                XCTAssertNotNil(directoryInfo.getValue(HiveDirectoryInfo.childCount))
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
        IpfsCommon().login(lock!, hiveClient: self.hiveClient!)

        // 1. nonarm create
        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for nonarm create")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }.then{ directory -> HivePromise<HiveDirectoryHandle> in
                return directory.createDirectory(withName: "ipfs_createD_\(timeTest!)")
            }.done{ directory in
                XCTAssertNotNil(directory.directoryId)
                XCTAssertNotNil(directory.drive)
                XCTAssertNotNil(directory.pathName)
                XCTAssertNotNil(directory.authHelper)
                XCTAssertNotNil(directory.lastInfo)
                XCTAssertNotNil(directory.lastInfo?.getValue(HiveDirectoryInfo.itemId))
                XCTAssertNotNil(directory.lastInfo?.getValue(HiveDirectoryInfo.name))
                XCTAssertNotNil(directory.lastInfo?.getValue(HiveDirectoryInfo.childCount))
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
                return directory.createDirectory(withName: "ipfs_createD_\(timeTest!)")
            }.done{ directory in
                XCTFail()
                self.lock?.fulfill()
            }.catch{ error in
                let des = HiveError.des(error as! HiveError)
                XCTAssertEqual(des, "IPFS unsuccessful: 500: file already exists")
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)
    }

    func testDirectoryHandle() {
        //    login
        lock = XCTestExpectation(description: "wait for test login.")
        IpfsCommon().login(lock!, hiveClient: self.hiveClient!)
        //   create directory
        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for test create directory.")
        IpfsCommon().creatDirectoryWithName(lock!, hiveClient: self.hiveClient!, timeTest!)

        //   1. get existing path directory
        lock = XCTestExpectation(description: "wait for get existing path directory.")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }.then{ directory -> HivePromise<HiveDirectoryHandle> in
                return directory.directoryHandle(atName: "ipfs_createD_\(timeTest!)")
            }.done{ directory in
                XCTAssertNotNil(directory.directoryId)
                XCTAssertNotNil(directory.drive)
                XCTAssertNotNil(directory.pathName)
                XCTAssertNotNil(directory.authHelper)
                XCTAssertNotNil(directory.lastInfo)
                XCTAssertNotNil(directory.lastInfo?.getValue(HiveDirectoryInfo.itemId))
                XCTAssertNotNil(directory.lastInfo?.getValue(HiveDirectoryInfo.name))
                XCTAssertNotNil(directory.lastInfo?.getValue(HiveDirectoryInfo.childCount))
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
                return directory.directoryHandle(atName: "ipfs_createD_\(timeTest!)_2")
            }.done{ directory in
                XCTFail()
                self.lock?.fulfill()
            }.catch{ error in
                let des = HiveError.des(error as! HiveError)
                XCTAssertEqual(des, "IPFS unsuccessful: 500: file does not exist")
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)
    }

    func testCreateFile() {
        //    login
        lock = XCTestExpectation(description: "wait for test login.")
        IpfsCommon().login(lock!, hiveClient: self.hiveClient!)
        // 1. create nanorm file
        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for create nanorm file")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }.then{ directory -> HivePromise<HiveFileHandle> in
                directory.createFile(withName: "ipfs_createF_\(timeTest!)")
            }.done{ file in
                XCTAssertNotNil(file.fileId)
                XCTAssertNotNil(file.drive)
                XCTAssertNotNil(file.pathName)
                XCTAssertNotNil(file.authHelper)
                XCTAssertNotNil(file.lastInfo)
                XCTAssertNotNil(file.lastInfo?.getValue(HiveFileInfo.itemId))
                XCTAssertNotNil(file.lastInfo?.getValue(HiveFileInfo.name))
                XCTAssertNotNil(file.lastInfo?.getValue(HiveFileInfo.size))
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
                directory.createFile(withName: "ipfs_createF_\(timeTest!)")
            }.done{ file in
                self.lock?.fulfill()
            }.catch{ error in
                XCTFail()
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)
    }

    func testFileHandle() {
        //    login
        lock = XCTestExpectation(description: "wait for test login.")
        IpfsCommon().login(lock!, hiveClient: self.hiveClient!)

        // create file
        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for create file.")
        IpfsCommon().createFileWithName(lock!, hiveClient: self.hiveClient!, timeTest!)

        // 1. get existing path file
        lock = XCTestExpectation(description: "wait for get existing path file")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }.then{ directory -> HivePromise<HiveFileHandle> in
                return directory.fileHandle(atName: "ipfs_createF_\(timeTest!)")
            }.done{ file in
                XCTAssertNotNil(file.fileId)
                XCTAssertNotNil(file.drive)
                XCTAssertNotNil(file.pathName)
                XCTAssertNotNil(file.authHelper)
                XCTAssertNotNil(file.lastInfo)
                XCTAssertNotNil(file.lastInfo?.getValue(HiveFileInfo.itemId))
                XCTAssertNotNil(file.lastInfo?.getValue(HiveFileInfo.name))
                XCTAssertNotNil(file.lastInfo?.getValue(HiveFileInfo.size))
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
                return directory.fileHandle(atName: "ipfs_createF_\(timeTest!)_2")
            }.done{ file in
                XCTFail()
                self.lock?.fulfill()
            }.catch{ error in
                let des = HiveError.des(error as! HiveError)
                XCTAssertEqual(des, "IPFS unsuccessful: 500: file does not exist")
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)
    }

    func testGetChildren() {
        //    login
        lock = XCTestExpectation(description: "wait for test login.")
        IpfsCommon().login(lock!, hiveClient: self.hiveClient!)

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
        IpfsCommon().login(lock!, hiveClient: self.hiveClient!)
        //   create directory
        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for test create directory.")
        IpfsCommon().creatDirectoryWithName(lock!, hiveClient: self.hiveClient!, timeTest!)
        //   create directory 2
        lock = XCTestExpectation(description: "wait for test create directory.")
        IpfsCommon().creatDirectoryWithName(lock!, hiveClient: self.hiveClient!, (timeTest! + "_2"))

        // 1. copy to an exisiting directory
        lock = XCTestExpectation(description: "wait for copy to an exisiting directory")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }.then{ directory -> HivePromise<HiveDirectoryHandle> in
                return directory.directoryHandle(atName: "ipfs_createD_\(timeTest!)")
            }.then{ directory -> HivePromise<Void> in
                return directory.copyTo(newPath: "/ipfs_createF_\(timeTest! + "_2")")
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
                return directory.directoryHandle(atName: "ipfs_createD_\(timeTest!)")
            }.then{ directory -> HivePromise<Void> in
                return directory.copyTo(newPath: "/ipfs_createF_\(timeTest!)")
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
                return directory.directoryHandle(atName: "ipfs_createD_\(timeTest!)")
            }.then{ directory -> HivePromise<Void> in
                return directory.copyTo(newPath: "/ipfs_createF_\(timeTest! + "_2")")
            }.done{ re in
                XCTFail()
                self.lock?.fulfill()
            }.catch{ error in
                XCTAssertTrue(true)
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)
    }

    func testDeleteItem() {
        //    login
        lock = XCTestExpectation(description: "wait for test login.")
        IpfsCommon().login(lock!, hiveClient: self.hiveClient!)
        //   create directory
        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for test create directory.")
        IpfsCommon().creatDirectoryWithName(lock!, hiveClient: self.hiveClient!, timeTest!)

        // 1. delete a exisiting directory
        lock = XCTestExpectation(description: "wait for delete a exisiting directory")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }.then{ directory -> HivePromise<HiveDirectoryHandle> in
                return directory.directoryHandle(atName: "ipfs_createD_\(timeTest!)")
            }.then{ directory -> HivePromise<Void> in
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
        IpfsCommon().login(lock!, hiveClient: self.hiveClient!)
        //   create directory
        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for test create directory.")
        IpfsCommon().creatDirectoryWithName(lock!, hiveClient: self.hiveClient!, timeTest!)
        //   create directory 2
        lock = XCTestExpectation(description: "wait for test create directory.")
        IpfsCommon().creatDirectoryWithName(lock!, hiveClient: self.hiveClient!, (timeTest! + "_2"))

        //   1. move to an exisiting directory
        lock = XCTestExpectation(description: "wait for move to an exisiting directory")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }.then{ directory -> HivePromise<HiveDirectoryHandle> in
                return directory.directoryHandle(atName: "/ipfs_createD_\(timeTest!)")
            }.then{ directory -> HivePromise<Void> in
                return directory.moveTo(newPath: "/ipfs_createD_\(timeTest! + "_2")")
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
                return directory.directoryHandle(atName: "/ipfs_createD_\(timeTest! + "_2")/ipfs_createD_\(timeTest!)")
            }.then{ directory -> HivePromise<Void> in
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
