
import XCTest
@testable import ElastosHiveSDK
@testable import ElastosDIDSDK

class VaultAuthenticator: Authenticator {
    func requestAuthentication(_ requestURL: String) -> HivePromise<String> {
        return HivePromise<String> { resolver in
            resolver.fulfill("eyJhbGciOiAiRVMyNTYiLCAidHlwZSI6ICJKV1QiLCAidmVyc2lvbiI6ICIxLjAiLCAia2lkIjogImRpZDplbGFzdG9zOmlZZ0Q0a3BXYWtRaUJCOWEzTUJUVXg4VzJFMnFlb2pkTjUjcHJpbWFyeSJ9.eyJpc3MiOiJkaWQ6ZWxhc3RvczppWWdENGtwV2FrUWlCQjlhM01CVFV4OFcyRTJxZW9qZE41Iiwic3ViIjoiRElEQXV0aFJlc3BvbnNlIiwiYXVkIjoiZGlkOmVsYXN0b3M6aVlnRDRrcFdha1FpQkI5YTNNQlRVeDhXMkUycWVvamRONSIsImlhdCI6MTYwMDA1MzczNiwiZXhwIjoyMjAwMDUzNzM2LCJuYmYiOjE2MDAwNTM3MzYsInByZXNlbnRhdGlvbiI6eyJ0eXBlIjoiVmVyaWZpYWJsZVByZXNlbnRhdGlvbiIsImNyZWF0ZWQiOiIyMDIwLTA5LTE0VDAzOjIyOjE2WiIsInZlcmlmaWFibGVDcmVkZW50aWFsIjpbeyJpZCI6ImRpZDplbGFzdG9zOmlZZ0Q0a3BXYWtRaUJCOWEzTUJUVXg4VzJFMnFlb2pkTjUjZGlkYXBwIiwidHlwZSI6WyJBcHBJZENyZWRlbnRpYWwiXSwiaXNzdWVyIjoiZGlkOmVsYXN0b3M6aVlnRDRrcFdha1FpQkI5YTNNQlRVeDhXMkUycWVvamRONSIsImlzc3VhbmNlRGF0ZSI6IjIwMjAtMDktMTRUMDM6MjI6MTZaIiwiZXhwaXJhdGlvbkRhdGUiOiIyMDI1LTA5LTEzVDAxOjE4OjIzWiIsImNyZWRlbnRpYWxTdWJqZWN0Ijp7ImlkIjoiZGlkOmVsYXN0b3M6aVlnRDRrcFdha1FpQkI5YTNNQlRVeDhXMkUycWVvamRONSIsImFwcERpZCI6ImFwcElkIn0sInByb29mIjp7InR5cGUiOiJFQ0RTQXNlY3AyNTZyMSIsInZlcmlmaWNhdGlvbk1ldGhvZCI6ImRpZDplbGFzdG9zOmlZZ0Q0a3BXYWtRaUJCOWEzTUJUVXg4VzJFMnFlb2pkTjUjcHJpbWFyeSIsInNpZ25hdHVyZSI6Im81VlFrNU5tdzV0aDJLREMwY0EzVkRrUmVnMmwwNHlvYXBVZ1k3Q1Mwb2lfeVZpZWJqQm12WVZEM1gyRkVaWl9sbXl0WjczckMzaDRDYVBFNHlrX3hBIn19XSwicHJvb2YiOnsidHlwZSI6IkVDRFNBc2VjcDI1NnIxIiwidmVyaWZpY2F0aW9uTWV0aG9kIjoiZGlkOmVsYXN0b3M6aVlnRDRrcFdha1FpQkI5YTNNQlRVeDhXMkUycWVvamRONSNwcmltYXJ5IiwicmVhbG0iOiJkaWQ6ZWxhc3RvczppWWdENGtwV2FrUWlCQjlhM01CVFV4OFcyRTJxZW9qZE41Iiwibm9uY2UiOiI3NjBiMDYxNi1mNjM5LTExZWEtYTQ2ZS1jNGIzMDE5MjZmZDgiLCJzaWduYXR1cmUiOiI3VlJ1MjZrYnRINmVpTG10Z1RzaEw0QkRYYk5sZkRrTkZQbTZwVXY5bEVRdkR1U2ROa29GdlB2TmFMT2ViX1BwSkMwU1lnZC1Tel83dnNKQ0ZQNkZldyJ9fX0.JoWCukek6GGqXWi4hyphT-8SglqptgAs9y5uckv5e_112mrvyR1dBNlY8pDZP3wl2eglKdNc29VM63r7xWpeJg")
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
