import XCTest
@testable import ElastosHiveSDK

class oneDriveClientTest: XCTestCase {
    private let CLIENT_ID = "fakeClientId"
    private let REDIRECT_URL = "http://localhost:12345"
    private let STORE_PATH = "fakePath"

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
