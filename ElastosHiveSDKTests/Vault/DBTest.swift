
import XCTest
@testable import ElastosHiveSDK
@testable import ElastosDIDSDK

class DBTest: XCTestCase {
    private let localDataPath = "\(NSHomeDirectory())/Library/Caches/store"
    private var client: HiveClientHandle?
    private var database: DatabaseClient?

    class VaultAuthenticator: Authenticator {
        func requestAuthentication(_ requestURL: String) -> HivePromise<String> {
            return HivePromise<String> { resolver in
                resolver.fulfill("eyJhbGciOiAiRVMyNTYiLCAidHlwZSI6ICJKV1QiLCAidmVyc2lvbiI6ICIxLjAiLCAia2lkIjogImRpZDplbGFzdG9zOmlqVW5ENEtlUnBlQlVGbWNFRENiaHhNVEpSelVZQ1FDWk0jcHJpbWFyeSJ9.eyJpc3MiOiJkaWQ6ZWxhc3RvczppalVuRDRLZVJwZUJVRm1jRURDYmh4TVRKUnpVWUNRQ1pNIiwic3ViIjoiRElEQXV0aFJlc3BvbnNlIiwiYXVkIjoiZGlkOmVsYXN0b3M6aWpVbkQ0S2VScGVCVUZtY0VEQ2JoeE1USlJ6VVlDUUNaTSIsImlhdCI6MTU5OTY0OTQ5NiwiZXhwIjoxNjAwMjQ5NDk2LCJuYmYiOjE1OTk2NDk0OTYsInByZXNlbnRhdGlvbiI6eyJ0eXBlIjoiVmVyaWZpYWJsZVByZXNlbnRhdGlvbiIsImNyZWF0ZWQiOiIyMDIwLTA5LTA5VDExOjA0OjU2WiIsInZlcmlmaWFibGVDcmVkZW50aWFsIjpbeyJpZCI6ImRpZDplbGFzdG9zOmlqVW5ENEtlUnBlQlVGbWNFRENiaHhNVEpSelVZQ1FDWk0jZGlkYXBwIiwidHlwZSI6WyJBcHBJZENyZWRlbnRpYWwiXSwiaXNzdWVyIjoiZGlkOmVsYXN0b3M6aWpVbkQ0S2VScGVCVUZtY0VEQ2JoeE1USlJ6VVlDUUNaTSIsImlzc3VhbmNlRGF0ZSI6IjIwMjAtMDktMDlUMTE6MDQ6NTZaIiwiZXhwaXJhdGlvbkRhdGUiOiIyMDI0LTEyLTI3VDA4OjUzOjI3WiIsImNyZWRlbnRpYWxTdWJqZWN0Ijp7ImlkIjoiZGlkOmVsYXN0b3M6aWpVbkQ0S2VScGVCVUZtY0VEQ2JoeE1USlJ6VVlDUUNaTSIsImFwcERpZCI6ImFwcElkIn0sInByb29mIjp7InR5cGUiOiJFQ0RTQXNlY3AyNTZyMSIsInZlcmlmaWNhdGlvbk1ldGhvZCI6ImRpZDplbGFzdG9zOmlqVW5ENEtlUnBlQlVGbWNFRENiaHhNVEpSelVZQ1FDWk0jcHJpbWFyeSIsInNpZ25hdHVyZSI6IkF5bXFTRUh0U1RGZndWN2JQRDBOTXVVdXdydS1DalAwZVA5ODd2eEw4OEhKZWhCcWN0dFpHVTFlRHpFaldrWDdsaElSS1Y3eUE2eHdyemVQbk9PVC1BIn19XSwicHJvb2YiOnsidHlwZSI6IkVDRFNBc2VjcDI1NnIxIiwidmVyaWZpY2F0aW9uTWV0aG9kIjoiZGlkOmVsYXN0b3M6aWpVbkQ0S2VScGVCVUZtY0VEQ2JoeE1USlJ6VVlDUUNaTSNwcmltYXJ5IiwicmVhbG0iOiJkaWQ6ZWxhc3RvczppalVuRDRLZVJwZUJVRm1jRURDYmh4TVRKUnpVWUNRQ1pNIiwibm9uY2UiOiI0MzZjOTZlZS1mMjhjLTExZWEtYTY0Yy1jNGIzMDE5MjZmZDgiLCJzaWduYXR1cmUiOiJZbjUzZkhZdGtlcmRuUXl3MUZaU2hvekJhS3pyV2FPaVJpeFU5dVZxZWFvRkdSRGlwRUNqdEEtNXdyb2w2cVlPb2NqTjNCbkxKQlAzRTU4MnlKM29iZyJ9fX0.86YCFmRXZyZw60LS447pMZqL-nuV84zPySB-WYSLwhHgrGeGcU13bFKHE7VWQ4y1UtySAlmLMMjJlVBpbmo4Nw")
            }
        }
    }

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
        let inserInfo = ["author": "john doe1", "title": "Eve for Dummies2"]
        database?.insertOne("new", inserInfo, options: nil).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            lock.fulfill()
            XCTFail()
        }
        self.wait(for: [lock], timeout: 1000.0)
    }

    /*
         @Test
         public void testInsertOne() {
             try {
                 ObjectNode docNode = JsonNodeFactory.instance.objectNode();
                 docNode.put("author", "john doe1");
                 docNode.put("title", "Eve for Dummies2");

     //            InsertOptions insertOptions = new InsertOptions();
     //            insertOptions.bypassDocumentValidation(false).ordered(true);

                 database.insertOne("works", docNode, /*insertOptions*/null, new Callback<InsertResult>() {
                     @Override
                     public void onError(HiveException e) {
                         fail();
                     }

                     @Override
                     public void onSuccess(InsertResult result) {
                         assertNotNull(result);
                         System.out.println("acknowledged="+result.get("acknowledged"));
                         System.out.println("inserted_id="+result.get("inserted_id"));
                     }
                 }).get();
             } catch (Exception e) {
                 e.printStackTrace();
             }
         }
     */

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
            _ = options.setLocalDataPath(self.localDataPath)
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
