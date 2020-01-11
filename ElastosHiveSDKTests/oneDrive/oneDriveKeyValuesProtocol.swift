import XCTest
@testable import ElastosHiveSDK

class oneDriveKeyValuesProtocolTest: XCTestCase {
    private let CLIENT_ID = "fakeClientId"
    private let REDIRECT_URL = "http://localhost:12345"
    private let STORE_PATH = "fakePath"

    private var client: HiveClientHandle?
    private var keyValuesProtocol: KeyValuesProtocol?

    class FakeAuthenticator: Authenticator {
        func requestAuthentication(_ requestURL: String) -> Bool {
            return true
        }
    }

    func testPutValue() {
        _ = keyValuesProtocol!.putValue("hello", forKey: "testHello")
    }

    func testPutData2() {
        // TODO
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

            try client?.connect()
            XCTAssertTrue(client!.isConnected())

            keyValuesProtocol = client!.asKeyValues()
            XCTAssertNotNil(keyValuesProtocol)

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
        client?.disconnect()
        client = nil
    }
}
