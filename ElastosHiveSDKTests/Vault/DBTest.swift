
import XCTest
@testable import ElastosHiveSDK
import ElastosDIDSDK

let p = PresentationJWT()
let testapp = DApp("testapp", "height uphold laundry enhance prepare surface catch close analyst badge force absorb", p.adapter!)
let didapp = DIDApp("didapp", "foster control ordinary fan sadness aware forest surge decorate cover student cram", p.adapter!)

class VaultAuthenticator: Authenticator {
    func requestAuthentication(_ jwtToken: String) -> HivePromise<String> {
        return HivePromise<String> { resolver in
            do{
                //SignIn
                let doc = try testapp.getDocument()
//                let doc = try DIDDocument.convertToDIDDocument(fromJson: DOC_STR)
                let docStr = doc.toString(true, forSign: true)
                print(docStr)

                let c = try JwtParserBuilder().build().parseClaimsJwt(jwtToken).claims
                let iss: String = c.getIssuer()!
                let nonce: String = c.get(key: "nonce") as! String
                let vc: VerifiableCredential = try didapp.issueDiplomaFor(testapp)
                let vp = try testapp.createPresentation(vc, iss, nonce)
                let vpIs = vp.isValid
                print("vpIs == \(vpIs)")
                let token = try testapp.createToken(vp, iss)
                let ddd = try JwtParserBuilder().build().parseClaimsJwt(token)
                let claim = ddd.claims
                print(claim.get(key: "presentation"))
                print(claim.get(key: "presentation"))
                print(token)
                let toks = token.split(separator: ".")
                let str  = "\(toks[0]).\(toks[1])"
                let test = try doc.verify(signature: "\(toks[2])", onto: str.data(using: String.Encoding.utf8)!)
                print("doc.verify = \(test)")
                try p.waitForWalletAvaliable()
                resolver.fulfill(token)
            }
            catch {
                resolver.reject(error)
            }
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
                print("testDbCreate error.")
                print(error)
                XCTFail()
                lock.fulfill()
            }
        self.wait(for: [lock], timeout: 1000000.0)
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

    func testUpdateManyWith$param() {
        let dic = ["_error": ["message": "Exception: method: 'query_update_one', Err: The dollar ($) prefixed field '$set' in '$set' is not valid for storage., full error: {'index': 0, 'code': 52, 'errmsg': \"The dollar ($) prefixed field '$set' in '$set' is not valid for storage.\"}", "code": 500]]
        let data = try? JSONSerialization.data(withJSONObject: dic as Any, options: [])
        let dicStr = String(data: data!, encoding: String.Encoding.utf8)!
        print(dicStr)

        let lock = XCTestExpectation(description: "wait for test.")
        let filterInfo = ["myParam": "hey"]
        let update = ["myParam": "hey", "randomParam": "0.7522371070254117"]
        let updateOptions = UpdateOptions()
        database?.updateMany("new0", filterInfo, update, options: updateOptions).done{ result in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            let e = HiveError.description(error as! HiveError)
            print(e)
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
            let doc = try DIDDocument.convertToDIDDocument(fromJson: DOC_STR)
//            let doc = try testapp.getDocument()
            print("testapp doc ===")
//            print(doc.toString())
//            let d = try didapp.getDocument()
//            print(d.toString())
            try HiveClientHandle.setupResolver(resolver, didCachePath)
            let options: HiveClientOptions = HiveClientOptions()
            _ = options.setLocalDataPath(localDataPath)
            _ = options.setAuthenticator(VaultAuthenticator())
            options.setAuthenticationDIDDocument(doc)
            HiveClientHandle.setVaultProvider(doc.subject.description, PROVIDER)
            self.client = try HiveClientHandle.createInstance(withOptions: options)
            let lock = XCTestExpectation(description: "wait for test.")
            _ = self.client?.getVault(doc.subject.description).get{ result in
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
