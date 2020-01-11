import XCTest
@testable import ElastosHiveSDK

class oneDriveClientConnectTest: XCTestCase {
    private let CLIENT_ID = "fakeClientId"
    private let REDIRECT_URL = "http://localhost:12345"
    private let STORE_PATH = "fakePath"

    private var client: HiveClientHandle?

    class FakeAuthenticator: Authenticator {
        func requestAuthentication(_ requestURL: String) -> Bool {
            return true
        }
    }

    func testConnect() {
        XCTAssertFalse(client!.isConnected())
        do {
            try client?.connect()
            XCTAssertTrue(client!.isConnected())
        } catch HiveError.failue {
            XCTFail()
        } catch {
            XCTFail()
        }
    }

    override func setUp() {
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

            client = try HiveClientHandle.createInstance(withOptions: options)
            XCTAssertNotNil(client)

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

    override func tearDown() {
        client = nil
    }
}

