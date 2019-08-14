

import XCTest
@testable import ElastosHiveSDK


class HiveIpfsDriveTests: XCTestCase {

    var hiveClient: HiveClientHandle?
    var hiveParams: DriveParameter?
    let rpcAddrs: IPFSEntry = IPFSEntry(addrs)
    let store: String = "\(NSHomeDirectory())/Library/Caches/ipfs"
    var lock: XCTestExpectation?
    var timeout: Double = 600.0

    override func setUp() {
        hiveParams = IPFSParameter(rpcAddrs,store)
        HiveClientHandle.createInstance(hiveParams!)
        hiveClient = HiveClientHandle.sharedInstance(type: .hiveIPFS)
    }

    func testLastUpdatedInfo() {
        // 1. Test lastUdateInfo after login
        lock = XCTestExpectation(description: "wait for test login.")
        //    anyway login
        IpfsCommon().login(lock!, hiveClient: self.hiveClient!)
        lock = XCTestExpectation(description: "wait for test lastUpateInfo after login.")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDriveInfo> in
                return drive.lastUpdatedInfo()
            }
            .done{ driveInfo in
                XCTAssertNotNil(driveInfo.getValue(HiveDriveInfo.driveId))
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
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDriveInfo> in
                return drive.lastUpdatedInfo()
            }
            .done{ driveInfo in
                XCTAssertNotNil(driveInfo.getValue(HiveDriveInfo.driveId))
                self.lock?.fulfill()
            }
            .catch{ error in
                let des = HiveError.des(error as! HiveError)
                XCTAssertEqual(des, "Please login first")
                self.lock?.fulfill()
        }
    }

    func testRootDirectoryHandle() {
        // 1. Test lastUdateInfo after login
        lock = XCTestExpectation(description: "wait for test login.")
        //    anyway login
        IpfsCommon().login(lock!, hiveClient: self.hiveClient!)
        lock = XCTestExpectation(description: "wait for test rootDirectoryHandle after login.")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }
            .done{ directory in
                XCTAssertNotNil(directory.directoryId)
                XCTAssertNotNil(directory.drive)
                XCTAssertNotNil(directory.pathName)
                XCTAssertNotNil(directory.authHelper)
                XCTAssertNotNil(directory.lastInfo)
                XCTAssertNotNil(directory.lastInfo?.getValue(HiveDirectoryInfo.itemId))
                XCTAssertNotNil(directory.lastInfo?.getValue(HiveDirectoryInfo.name))
                XCTAssertNotNil(directory.lastInfo?.getValue(HiveDirectoryInfo.childCount))
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

        lock = XCTestExpectation(description: "wait for test rootDirectoryHandle after logout.")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }
            .done{ directory in
                XCTAssertNotNil(directory.directoryId)
                XCTAssertNotNil(directory.drive)
                XCTAssertNotNil(directory.pathName)
                XCTAssertNotNil(directory.authHelper)
                XCTAssertNotNil(directory.lastInfo)
                XCTAssertNotNil(directory.lastInfo?.getValue(HiveDirectoryInfo.itemId))
                XCTAssertNotNil(directory.lastInfo?.getValue(HiveDirectoryInfo.name))
                XCTAssertNotNil(directory.lastInfo?.getValue(HiveDirectoryInfo.childCount))
                self.lock?.fulfill()
            }
            .catch{ error in
                let des = HiveError.des(error as! HiveError)
                XCTAssertEqual(des, "Please login first")
                self.lock?.fulfill()
        }
    }

    func testCreateDirectory() {
        // 1. nonarm create
        lock = XCTestExpectation(description: "wait for test login.")
        //    login
        IpfsCommon().login(lock!, hiveClient: self.hiveClient!)
        // create nonarm directory
        lock = XCTestExpectation(description: "wait for create nonarm directory.")
        timeTest = Timestamp.getTimeAtNow()
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.createDirectory(withPath: "/ipfs_createD_\(timeTest!)")
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
        lock = XCTestExpectation(description: "wait for create same name directory.")
        self.hiveClient?.defaultDriveHandle().then{ drive -> HivePromise<HiveDirectoryHandle> in
            return drive.createDirectory(withPath: "/ipfs_createD_\(timeTest!)")
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
        //      login
        lock = XCTestExpectation(description: "wait for test login.")
        IpfsCommon().login(lock!, hiveClient: self.hiveClient!)
        //    create directory
        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for test create directory.")
        IpfsCommon().creatDirectory(lock!, hiveClient: self.hiveClient!, timeTest!)
        //   1. get existing path directory
        lock = XCTestExpectation(description: "wait for get existing path directory.")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.directoryHandle(atPath: "/ipfs_createD_\(timeTest!)")
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
                return drive.directoryHandle(atPath: "/ipfs_createD_\(timeTest!)_2")
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
        //     login
        lock = XCTestExpectation(description: "wait for test login.")
        IpfsCommon().login(lock!, hiveClient: self.hiveClient!)

        // 1. create nanorm file
        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for create nanarm file")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveFileHandle> in
                return drive.createFile(withPath: "/ipfs_createF_\(timeTest!)")
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
            .then{ drive -> HivePromise<HiveFileHandle> in
                return drive.createFile(withPath: "/ipfs_createF_\(timeTest!)")
            }.done{ file in
                self.lock?.fulfill()
            }.catch{ error in
                XCTFail()
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)
    }

    func testFileHandle() {
        //     login
        lock = XCTestExpectation(description: "wait for test login.")
        IpfsCommon().login(lock!, hiveClient: self.hiveClient!)

        // create a file
        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for create a file.")
        IpfsCommon().createFile(lock!, hiveClient: self.hiveClient!, timeTest!)
        // 1. get a existing file
        lock = XCTestExpectation(description: "wait for get a existing file")
        self.hiveClient?.defaultDriveHandle().then{ drive -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/ipfs_createF_\(timeTest!)")
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

        // 2. get a non-existing file
        lock = XCTestExpectation(description: "wait for get a non-existing file")
        self.hiveClient?.defaultDriveHandle().then{ drive -> HivePromise<HiveFileHandle> in
            return drive.fileHandle(atPath: "/ipfs_createF_\(timeTest!)_2")
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

    func testGetItemInfo() {
        //     login
        lock = XCTestExpectation(description: "wait for test login.")
        IpfsCommon().login(lock!, hiveClient: self.hiveClient!)

        //  create a file
        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for create a file.")
        IpfsCommon().createFile(lock!, hiveClient: self.hiveClient!, timeTest!)

        // 1. test an existing file getItemInfo
        lock = XCTestExpectation(description: "wait for test an existing file getItemInfo")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveItemInfo> in
                return drive.getItemInfo("/ipfs_createF_\(timeTest!)")
            }.done{ file in
                XCTAssertNotNil(file.getValue(HiveItemInfo.itemId))
                XCTAssertNotNil(file.getValue(HiveItemInfo.name))
                XCTAssertNotNil(file.getValue(HiveItemInfo.type))
                XCTAssertNotNil(file.getValue(HiveItemInfo.size))
                self.lock?.fulfill()
            }.catch{ error in
                XCTFail()
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)

        // 2. get a non-exisiting file getItemInfo
        lock = XCTestExpectation(description: "wait for test get a non-exisiting file getItemInfo")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveItemInfo> in
                return drive.getItemInfo("/ipfs_createF_\(timeTest!)_2")
            }.done{ file in
                XCTFail()
                self.lock?.fulfill()
            }.catch{ error in
                let des = HiveError.des(error as! HiveError)
                XCTAssertEqual(des, "IPFS unsuccessful: 500: file does not exist")
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)

        //  create directory
        timeTest = Timestamp.getTimeAtNow()
        lock = XCTestExpectation(description: "wait for test create directory.")
        IpfsCommon().creatDirectory(lock!, hiveClient: self.hiveClient!, timeTest!)

        // 3. test an existing directory getItemInfo
        lock = XCTestExpectation(description: "wait for test an existing directory getItemInfo")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveItemInfo> in
                return drive.getItemInfo("/ipfs_createD_\(timeTest!)")
            }.done{ file in
                XCTAssertNotNil(file.getValue(HiveItemInfo.itemId))
                XCTAssertNotNil(file.getValue(HiveItemInfo.name))
                XCTAssertNotNil(file.getValue(HiveItemInfo.type))
                XCTAssertNotNil(file.getValue(HiveItemInfo.size))
                self.lock?.fulfill()
            }.catch{ error in
                XCTFail()
                self.lock?.fulfill()
        }
        wait(for: [lock!], timeout: timeout)

        // 4. get a non-exisiting directory getItemInfo
        lock = XCTestExpectation(description: "wait for test get a non-exisiting directory getItemInfo")
        self.hiveClient?.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveItemInfo> in
                return drive.getItemInfo("/ipfs_createD_\(timeTest!)_2")
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

}
