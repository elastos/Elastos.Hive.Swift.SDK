import XCTest
@testable import ElastosHiveSDK

class oneDriveClientOptionsTest: XCTestCase {
    private let CLIENT_ID = "fakeClientId"
    private let REDIRECT_URL = "http://localhost:12345"
    private let STORE_PATH = "fakePath"

    class FakeAuthenticator: Authenticator {
        func requestAuthentication(_ requestURL: String) -> Bool {
            return true
        }
    }
    func testBuild() {
        do {
            let options = try OneDriveClientOptionsBuilder()
                .withClientId(CLIENT_ID)
                .withRedirectUrl(REDIRECT_URL)
                .withAuthenticator(FakeAuthenticator())
                .withStorePath(using: STORE_PATH)
                .build()

            XCTAssertNotNil(options)
            XCTAssertNotNil(options.clientId)
            XCTAssertNotNil(options.redirectUrl)
            XCTAssertNotNil(options.authenicator)
            XCTAssertNotNil(options.storePath)
        } catch HiveError.invalidatedBuilder  {
            XCTFail()
        } catch HiveError.insufficientParameters {
            XCTFail()
        } catch HiveError.failue  {
            XCTFail()
        }
    }

    func testBuildWithoutClientId() {
        do {
            let _ = try OneDriveClientOptionsBuilder()
                .withRedirectUrl(REDIRECT_URL)
                .withAuthenticator(FakeAuthenticator())
                .withStorePath(using: STORE_PATH)
                .build()

            XCTFail()
        } catch HiveError.invalidatedBuilder  {
            XCTFail()
        } catch HiveError.insufficientParameters {
            XCTAssertTrue(true)
        } catch HiveError.failue  {
            XCTFail()
        }
    }

    func testBuildWithoutRedirectUrl() {
        do {
            let _ = try OneDriveClientOptionsBuilder()
            .withClientId(CLIENT_ID)
            .withAuthenticator(FakeAuthenticator())
            .withStorePath(using: STORE_PATH)
            .build()

            XCTFail()
        } catch HiveError.invalidatedBuilder  {
            XCTFail()
        } catch HiveError.insufficientParameters {
            XCTAssertTrue(true)
        } catch HiveError.failue  {
            XCTFail()
        }
    }

    func testBuildWithoutAuthenticator() {
        do {
            let _ = try OneDriveClientOptionsBuilder()
            .withClientId(CLIENT_ID)
            .withRedirectUrl(REDIRECT_URL)
            .withStorePath(using: STORE_PATH)
            .build()

            XCTFail()
        } catch HiveError.invalidatedBuilder  {
            XCTFail()
        } catch HiveError.insufficientParameters {
            XCTAssertTrue(true)
        } catch HiveError.failue  {
            XCTFail()
        }
    }

    func testBuildWithoutStorePath() {
        do {
            let _ = try OneDriveClientOptionsBuilder()
            .withClientId(CLIENT_ID)
            .withRedirectUrl(REDIRECT_URL)
            .withAuthenticator(FakeAuthenticator())
            .build()

            XCTFail()
        } catch HiveError.invalidatedBuilder  {
            XCTFail()
        } catch HiveError.insufficientParameters {
            XCTAssertTrue(true)
        } catch HiveError.failue  {
            XCTFail()
        }
    }

    override func setUp() {
    }

    override func tearDown() {
    }
}
