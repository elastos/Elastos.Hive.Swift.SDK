import XCTest
@testable import ElastosHiveSDK

class oneDriveClientOptionsTest: XCTestCase {
    private let CLIENT_ID = "afd3d647-a8b7-4723-bf9d-1b832f43b881"
    private let REDIRECT_URL = "http://localhost:12345"
    private let STORE_PATH = "\(NSHomeDirectory())/Library/Caches/onedrive"

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
        } catch {
            XCTFail()
        }
    }

    func testBuildWithoutClientId() {
        do {
            _ = try OneDriveClientOptionsBuilder()
                .withRedirectUrl(REDIRECT_URL)
                .withAuthenticator(FakeAuthenticator())
                .withStorePath(using: STORE_PATH)
                .build()

        } catch HiveError.invalidatedBuilder {
            XCTFail()
        } catch HiveError.insufficientParameters {
            XCTAssertTrue(true)
        } catch HiveError.failue {
            XCTFail()
        } catch {
            XCTFail()
        }
    }

    func testBuildWithoutRedirectUrl() {
        do {
            _ = try OneDriveClientOptionsBuilder()
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
        } catch {
            XCTFail()
        }
    }

    func testBuildWithoutAuthenticator() {
        do {
            _ = try OneDriveClientOptionsBuilder()
                .withClientId(CLIENT_ID)
                .withRedirectUrl(REDIRECT_URL)
                .withStorePath(using: STORE_PATH)
                .build()

            XCTFail()
        } catch HiveError.invalidatedBuilder  {
            XCTFail()
        } catch HiveError.insufficientParameters {
            XCTAssertTrue(true)
        } catch {
            XCTFail()
        }
    }

    func testBuildWithoutStorePath() {
        do {
            _ = try OneDriveClientOptionsBuilder()
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
        } catch {
            XCTFail()
        }
    }

    override func setUp() {}
    override func tearDown() {}
}
