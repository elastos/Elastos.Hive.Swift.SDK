
import XCTest
@testable import ElastosHiveSDK
@testable import ElastosDIDSDK

class VaultAuthenticator: Authenticator {
    func requestAuthentication(_ requestURL: String) -> HivePromise<String> {
        return HivePromise<String> { resolver in
            resolver.fulfill("eyJhbGciOiAiRVMyNTYiLCAidHlwZSI6ICJKV1QiLCAidmVyc2lvbiI6ICIxLjAiLCAia2lkIjogImRpZDplbGFzdG9zOmlkZnBLSkoxc29EeFQyR2NnQ1JuRHQzY3U5NFpuR2Z6TlgjcHJpbWFyeSJ9.eyJpc3MiOiJkaWQ6ZWxhc3RvczppZGZwS0pKMXNvRHhUMkdjZ0NSbkR0M2N1OTRabkdmek5YIiwic3ViIjoiRElEQXV0aFJlc3BvbnNlIiwiYXVkIjoiZGlkOmVsYXN0b3M6aVlnRDRrcFdha1FpQkI5YTNNQlRVeDhXMkUycWVvamRONSIsImlhdCI6MTYwMDI0NDA3NywiZXhwIjo2MDAwMDE2MDAyNDQwNzcsIm5iZiI6MTYwMDI0NDA3NywicHJlc2VudGF0aW9uIjp7InR5cGUiOiJWZXJpZmlhYmxlUHJlc2VudGF0aW9uIiwiY3JlYXRlZCI6IjIwMjAtMDktMTZUMDg6MTQ6MzdaIiwidmVyaWZpYWJsZUNyZWRlbnRpYWwiOlt7ImlkIjoiZGlkOmVsYXN0b3M6aWRmcEtKSjFzb0R4VDJHY2dDUm5EdDNjdTk0Wm5HZnpOWCNkaWRhcHAiLCJ0eXBlIjpbIkFwcElkQ3JlZGVudGlhbCJdLCJpc3N1ZXIiOiJkaWQ6ZWxhc3RvczppajhrckFWUkppdFpLSm1jQ3Vmb0xIUWpxN01lZjNaalROIiwiaXNzdWFuY2VEYXRlIjoiMjAyMC0wOS0xNlQwODoxNDozN1oiLCJleHBpcmF0aW9uRGF0ZSI6IjIwMjUtMDktMDFUMTk6NDc6MjRaIiwiY3JlZGVudGlhbFN1YmplY3QiOnsiaWQiOiJkaWQ6ZWxhc3RvczppZGZwS0pKMXNvRHhUMkdjZ0NSbkR0M2N1OTRabkdmek5YIiwiYXBwRGlkIjoiYXBwSWQifSwicHJvb2YiOnsidHlwZSI6IkVDRFNBc2VjcDI1NnIxIiwidmVyaWZpY2F0aW9uTWV0aG9kIjoiZGlkOmVsYXN0b3M6aWo4a3JBVlJKaXRaS0ptY0N1Zm9MSFFqcTdNZWYzWmpUTiNwcmltYXJ5Iiwic2lnbmF0dXJlIjoickxYYkRYWU9EX2xqcUpyR0UtbDVtcjU3VkxFYzVFUFA3ZDg4dHo3cmZGRHpaQVlTSnNyX00wbVRxYzVDbXFrV2EtMkpGWDBodEZEbmpMLXVEbXBZakEifX1dLCJwcm9vZiI6eyJ0eXBlIjoiRUNEU0FzZWNwMjU2cjEiLCJ2ZXJpZmljYXRpb25NZXRob2QiOiJkaWQ6ZWxhc3RvczppZGZwS0pKMXNvRHhUMkdjZ0NSbkR0M2N1OTRabkdmek5YI3ByaW1hcnkiLCJyZWFsbSI6ImRpZDplbGFzdG9zOmlZZ0Q0a3BXYWtRaUJCOWEzTUJUVXg4VzJFMnFlb2pkTjUiLCJub25jZSI6ImE1ZjA0MDFlLWY3ZjQtMTFlYS04M2U0LWM0YjMwMTkyNmZkOCIsInNpZ25hdHVyZSI6IkdzMjRNTXdQSFJrOTBGN0tJZUxzc3JNYUFNUUlPV29uTU5FTjhhQ29OOVg3RDVJX2s1ZHIwdXpyYWU2QjltREJBOFBxdm9CVjZYRzNTaXhzaEljbEF3In19fQ.g1B3xdJ2V7lnq1ssCujXbIXyeCaVPSzXEhQwVDwtv-EpP44SuENwbhZ_ejhwMExUxcU7_GLlJXhAQ14ydPl_oA")
        }
    }
}

class DBTest: XCTestCase {
    private var client: HiveClientHandle?
    private var database: DatabaseClient?

    func testDbCreate() {
        let lock = XCTestExpectation(description: "wait for test.")
            _ = database?.createCollection("new").done{ result in
                XCTAssertTrue(true)
                lock.fulfill()
            }.catch{ error in
                XCTFail()
                lock.fulfill()
            }
        self.wait(for: [lock], timeout: 100.0)
    }

    func testDeleteCollection() {
        let lock = XCTestExpectation(description: "wait for test.")
        database?.deleteCollection("new").done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func testInsertOne() {
        let lock = XCTestExpectation(description: "wait for test.")
        let inserInfo = ["author": "john doe1", "title": "Eve for Dummies1"]
        database?.insertOne("new", inserInfo, options: nil).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func testInsertMany() {
        let lock = XCTestExpectation(description: "wait for test.")
        let inserInfo1 = ["author": "john doe1", "title": "Eve for Dummies1"]
        let inserInfo2 = ["author": "john doe2", "title": "Eve for Dummies2"]
        let insertOptions = InsertOptions()
        database?.insertMany("new", [inserInfo1, inserInfo2], options: insertOptions).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func testCountDocuments() {
        let lock = XCTestExpectation(description: "wait for test.")
        let filter = ["author": "john doe2"]
        let options = CountOptions()
//        options.limit(1).skip(0).maxTimeMS(1000000000); //TODO:
        database?.countDocuments("new", filter, options: options).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func testFindOne() {
        let lock = XCTestExpectation(description: "wait for test.")
        let queryInfo = ["author": "john doe1"]

        let findOptions = FindOptions()
        database?.findOne("new", queryInfo, options: findOptions).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func testFindMany() {
        let lock = XCTestExpectation(description: "wait for test.")
        let queryInfo = ["author": "john doe1"]

        let findOptions = FindOptions()
        database?.findMany("new", queryInfo, options: findOptions).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func testUpdateOne() {
        let lock = XCTestExpectation(description: "wait for test.")
        let filterInfo = ["author": "john doe1"]
        let update = ["author": "john doe2_1", "title": "Eve for Dummies2_1_1"]
        let updateOptions = UpdateOptions()
        database?.updateOne("new", filterInfo, update, options: updateOptions).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }


    func testUpdateMany() {
        let lock = XCTestExpectation(description: "wait for test.")
        let filterInfo = ["author": "john doe1"]
        let update = ["author": "john doe2_1", "title": "Eve for Dummies2_1_1_2"]
        let updateOptions = UpdateOptions()
        database?.updateMany("new", filterInfo, update, options: updateOptions).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func testDeleteOne() {
        let lock = XCTestExpectation(description: "wait for test.")
        let filterInfo = ["author": "john doe2"]
        let deleteOptions = DeleteOptions()
        database?.deleteOne("new", filterInfo, options: deleteOptions).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    func testDeleteMany() {
        let lock = XCTestExpectation(description: "wait for test.")
        let filterInfo = ["author": "john doe2"]
        let deleteOptions = DeleteOptions()
        database?.deleteMany("new", filterInfo, options: deleteOptions).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
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
                self.database = (result.database as! DatabaseClient)
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
