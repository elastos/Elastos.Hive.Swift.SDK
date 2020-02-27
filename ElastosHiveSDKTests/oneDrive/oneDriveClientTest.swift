import XCTest
@testable import ElastosHiveSDK

class oneDriveClientTest: XCTestCase {
    private let CLIENT_ID = "afd3d647-a8b7-4723-bf9d-1b832f43b881"
    private let REDIRECT_URL = "http://localhost:12345"
    private let STORE_PATH = "\(NSHomeDirectory())/Library/Caches/onedrive"

    private var options: OneDriveClientOptions?

    class FakeAuthenticator: Authenticator {
        func requestAuthentication(_ requestURL: String) -> Bool {
            return true
        }
    }

    func testCreateInstance() {
        do {
            let client = try HiveClientHandle.createInstance(withOptions: options!)
            XCTAssertNotNil(client)
            XCTAssertFalse(client.isConnected())
        } catch HiveError.failue {
            XCTFail()
        } catch {
            XCTFail()
        }
    }

    override func setUp() {
        do {
            options = try OneDriveClientOptionsBuilder()
                .withClientId(CLIENT_ID)
                .withRedirectUrl(REDIRECT_URL)
                .withAuthenticator(FakeAuthenticator())
                .withStorePath(using: STORE_PATH)
                .build()

            XCTAssertNotNil(options)
            XCTAssertNotNil(options?.clientId)
            XCTAssertNotNil(options?.redirectUrl)
            XCTAssertNotNil(options?.authenicator)
            XCTAssertNotNil(options?.storePath)
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

    override func tearDown() {}
}
