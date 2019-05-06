//
//  HiveOneDriveFileTests.swift
//  ElastosHiveSDKTests
//
//  Created by 李爱红 on 2019/5/4.
//  Copyright © 2019 org.elastos. All rights reserved.
//

import XCTest
@testable import ElastosHiveSDK

class HiveOneDriveFileTests: XCTestCase {

    var hiveDrive: HiveDriveHandle?
    var hiveParam: DriveParameters?
    var hiveFile: HiveFileHandle?
    var lock: XCTestExpectation?
    var lock2: XCTestExpectation?
    var timeout: Double = 600.0

    override func setUp() {
        hiveParam = DriveParameters.createForOneDrive(applicationId: "31c2dacc-80e0-47e1-afac-faac093a739c", scopes: ["Files.ReadWrite","offline_access"], redirectUrl: REDIRECT_URI)
        HiveDriveHandle.createInstance(hiveParam!)
        hiveDrive = HiveDriveHandle.sharedInstance(type: .oneDrive)
    }

    override func tearDown() {
    }

    func test0_Login() {
        lock = XCTestExpectation(description: "wait for hiveDrive call login callback")
        hiveDrive?.login(withResult: { (result, error) in
            self.lock?.fulfill()
            XCTAssertTrue(result!, error.debugDescription)
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test1_parentHandle() {

        lock = XCTestExpectation(description: "wait for getFileHandle obain hiveFile")
        try? hiveDrive?.getFileHandle(atPath: "test1/test.txt", withResult: { (hf, er) in
            if hf != nil && er == nil {
                self.hiveFile = hf
                hf?.parentHandle(withResult: { (phf, er) in
                    self.lock?.fulfill()
                    XCTAssertNotNil(phf, er.debugDescription)
                    if phf != nil {
                        XCTAssertEqual("test1", phf?.name)
                    }
                })
            }else {
                XCTFail(er.debugDescription)
            }
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test2_updateDateTime() {
    }

    func test3_copyFileTo_newPath() {

        lock = XCTestExpectation(description: "wait for call getFileHandle callback")
        try? hiveDrive?.getFileHandle(atPath: "test2/test.txt", withResult: { (hf, er) in
            if hf != nil {
                try? hf?.deleteItem(withResult: { (re, er) in
                    self.lock?.fulfill()
                    XCTAssertTrue(re!, er.debugDescription)
                })
            }else {
                self.lock?.fulfill()
            }
        })
        wait(for: [lock!], timeout: timeout)

        lock = XCTestExpectation(description: "wait for getFileHandle obain hiveFile")
        try? hiveDrive?.getFileHandle(atPath: "test1/test.txt", withResult: { (hf, er) in
            self.lock?.fulfill()
            if hf != nil && er == nil {
                self.hiveFile = hf
            }else {
                XCTFail(er.debugDescription)
            }
        })
        wait(for: [lock!], timeout: timeout)

        lock = XCTestExpectation(description: "wait for call copyFileTo callback")
        try? self.hiveFile?.copyFileTo(newPath: "test2", withResult: { (re, er) in
            XCTAssertTrue(re!, er.debugDescription)
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test4_copyFileTo_newFile() {
    }

    func test5_renameFileTo_newPath() {

        lock = XCTestExpectation(description: "wait for getFileHandle obain hiveFile")
        try? hiveDrive?.getFileHandle(atPath: "test1/test.txt", withResult: { (hf, er) in
            if hf != nil && er == nil {
                self.hiveFile = hf
            }else {
                XCTFail(er.debugDescription)
            }
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)

        lock = XCTestExpectation(description: "wait for call getFileHandle obain test_rename hivefiel")
        try? hiveDrive?.getFileHandle(atPath: "test1/test_rename.txt", withResult: { (hf, er) in
            if hf != nil {
                try? hf?.deleteItem(withResult: { (re, er) in
                    XCTAssertTrue(re!, er.debugDescription)
                    self.lock?.fulfill()
                })
            }else {
                self.lock?.fulfill()
            }
        })
        wait(for: [lock!], timeout: timeout)

        lock = XCTestExpectation(description: "wait for call renameaFileTo callback")
        try? self.hiveFile?.renameFileTo(newPath: "test_rename.txt", withResult: { (re, er) in
            XCTAssertTrue(re!, er.debugDescription)
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test6_deleteItem() {
        lock = XCTestExpectation(description: "wait for getFileHandle obain hiveFile")
        try? hiveDrive?.getFileHandle(atPath: "test2/test.txt", withResult: { (hf, er) in
            if hf != nil && er == nil {
                self.hiveFile = hf
            }else {
                XCTFail(er.debugDescription)
            }
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
        
        lock = XCTestExpectation(description: "wait for deleItem callback")
        try? self.hiveFile?.deleteItem(withResult: { (re, er) in
            XCTAssertTrue(re!, re.debugDescription)
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)
    }

    func test7_closeItem() {

    }

    func test8_list() {
        lock = XCTestExpectation(description: "wait for call createFile callback")
        try? self.hiveDrive?.createFile(atPath: "test1/test.txt", withResult: { (hf, er) in
            if hf != nil {
                self.hiveFile = hf
            }
            XCTAssertNotNil(hf, er.debugDescription)
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)

        lock = XCTestExpectation(description: "wait for call list callback")
        try? self.hiveFile?.list(withResult: { (res, er) in
            self.lock?.fulfill()
        })
        wait(for: [lock!], timeout: timeout)

    }

    func test9_mkdir() {
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func getFile(path: String) -> HiveFileHandle? {
        lock = XCTestExpectation(description: "wait for getFileHandle obain hiveFile")
        try? hiveDrive?.getFileHandle(atPath: path, withResult: { (hf, er) in
            self.lock?.fulfill()
            if hf != nil && er == nil {
                self.hiveFile = hf
            }else {
                XCTFail(er.debugDescription)
            }
        })
        wait(for: [lock!], timeout: timeout)
        return self.hiveFile
    }

}
