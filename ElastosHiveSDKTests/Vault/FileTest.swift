
import XCTest
@testable import ElastosHiveSDK
@testable import ElastosDIDSDK

class FileTest: XCTestCase {
    private var client: HiveClientHandle?
    private var file: FileClient?

    func testUpload() {
        let lock = XCTestExpectation(description: "wait for test.")
        _ = file?.upload("hive/testIos.txt").done{ re in

        }.catch{ error in

        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func testDownload() {
        let lock = XCTestExpectation(description: "wait for test.")
        _ = file?.download("hive/testIos.txt").done{ re in

        }.catch{ error in

        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func testDelete() {
        let lock = XCTestExpectation(description: "wait for test.")
        _ = file?.delete("hive/testIos_delete01.txt").done{ re in
            XCTAssertTrue(re)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func testCopy() {
        let lock = XCTestExpectation(description: "wait for test.")
        _ = file?.copy("hive/testIos.txt", "hive/f1/testIos_copy_1.txt").done{ re in
            XCTAssertTrue(re)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func testMove() {
        let lock = XCTestExpectation(description: "wait for test.")
        _ = file?.move("hive/f1/testIos_copy_1.txt", "hive/f2/f3/testIos_move_1.txt").done{ re in
            XCTAssertTrue(re)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        do {
            let json = "{\"id\":\"did:elastos:inpxc8Tb1hKZGrqoYsJuH6VNnXpk3gi7UM\",\"publicKey\":[{\"id\":\"#primary\",\"publicKeyBase58\":\"pBvEfpUJK8FzWB7kD59henSfmZqBK8PqDBt53PczLqsG\"}],\"authentication\":[\"#primary\"],\"expires\":\"2025-09-08T05:43:06Z\",\"proof\":{\"created\":\"2020-09-08T05:43:06Z\",\"signatureValue\":\"rUg9Q1W9fW2yagpj4Ex97HHLMsrkRbjGKJQQn54joMvFJfochmMq5U-MFkgxsNQ9m0xCvCKO_JWv-OH2Ghc5Gw\"}}"

            let doc = try DIDDocument.convertToDIDDocument(fromJson: json)
            print(doc.toString())
            let options: HiveClientOptions = HiveClientOptions()
            _ = options.setAuthenticator(VaultAuthenticator())
            options.setAuthenticationDIDDocument(doc)
                .setDidResolverUrl("http://api.elastos.io:21606")
            _ = options.setLocalDataPath(localDataPath)
            HiveClientHandle.setVaultProvider("did:elastos:inpxc8Tb1hKZGrqoYsJuH6VNnXpk3gi7UM", "http://localhost:5000/")
            self.client = try HiveClientHandle.createInstance(withOptions: options)
            let lock = XCTestExpectation(description: "wait for test.")
            _ = self.client?.getVault("did:elastos:inpxc8Tb1hKZGrqoYsJuH6VNnXpk3gi7UM").get{ result in
                self.file = (result.files as! FileClient)
                lock.fulfill()
            }
            self.wait(for: [lock], timeout: 100.0)
        } catch {
            XCTFail()
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
