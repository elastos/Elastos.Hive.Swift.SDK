//
//  HiveOneDriveTests.swift
//  ElastosHiveSDK_macOSTests
//
//  Created by 李爱红 on 2019/5/3.
//  Copyright © 2019 org.elastos. All rights reserved.
//

import XCTest
@testable import ElastosHiveSDK_macOS

let REDIRECT_URI: String = "http://localhost:44316"

class HiveOneDriveTests: XCTestCase {

    var hiveDrive: HiveDriveHandle? = nil
    var hiveParam: DriveParameters? = nil
    var lock: XCTestExpectation?
    let timeout: Double = 600.0


    override func setUp() {

        hiveParam = DriveParameters.createForOneDrive(applicationId: "31c2dacc-80e0-47e1-afac-faac093a739c", scopes: ["Files.ReadWrite","offline_access"], redirectUrl: REDIRECT_URI)
        HiveDriveHandle.createInstance(hiveParam!)
        hiveDrive = HiveDriveHandle.sharedInstance(type: .oneDrive)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test1_Login() {
        lock = XCTestExpectation(description: "wait for hiveDrive call login callback")
        hiveDrive?.login(withResult: { (result, error) in
            self.lock?.fulfill()
            print(result)
        })
        wait(for: [lock!], timeout: timeout)
    }

    func testLogout() {

    }

    func test2_RootDirectoryHandle() {

        lock = XCTestExpectation(description: "wait for hiveDrive call rootDirectoryHandle")
       try? hiveDrive?.rootDirectoryHandle(withResult: { (hiveFile, error) in
            self.lock?.fulfill()
            XCTAssertNotNil(hiveFile, error.debugDescription)
        })
        wait(for: [lock!], timeout: timeout)
    }

    func testCreateDirectory() {

        // todo deledate
        lock = XCTestExpectation(description: "wait for getFileHandle callback")
        try? hiveDrive?.getFileHandle(atPath: "test1/test", withResult: { (hiveFile, error) in
            XCTAssertEqual("test", hiveFile.name)
        })

        lock = XCTestExpectation(description: "wait for hiveDrive call createFile callback")
        try? hiveDrive?.createFile(atPath: "test1/test", withResult: { (hiveFile, error) in
            self.lock?.fulfill()
            XCTAssertEqual("test", hiveFile.name)
        })
        wait(for: [lock!], timeout: timeout)
    }

    func testGetFileHandle() {
        try? hiveDrive?.getFileHandle(atPath: "test1/test1.txt", withResult: { (hiveFile, error) in

        })
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
