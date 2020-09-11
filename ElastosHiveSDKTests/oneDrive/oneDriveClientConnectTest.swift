import XCTest
@testable import ElastosHiveSDK
/*
class oneDriveClientConnectTest: XCTestCase {
    private let CLIENT_ID = "afd3d647-a8b7-4723-bf9d-1b832f43b881"
    private let REDIRECT_URL = "http://localhost:12345"
    private let STORE_PATH = "\(NSHomeDirectory())/Library/Caches/onedrive"

    private var client: HiveClientHandle?

    class FakeAuthenticator: Authenticator {
        func requestAuthentication(_ requestURL: String) -> Bool {
            DispatchQueue.main.sync {
                let authViewController: AuthWebViewController = AuthWebViewController()
                let rootViewController = UIApplication.shared.keyWindow?.rootViewController
                rootViewController!.present(authViewController, animated: true, completion: nil)
                authViewController.loadRequest(requestURL)
            }
            return true
        }
    }

    func testConnect() {
        let lock = XCTestExpectation(description: "wait for test connect.")
        let globalQueue = DispatchQueue.global()
        globalQueue.async {
            do {
                try self.client?.connect()
                XCTAssertTrue(self.client!.isConnected())
                lock.fulfill()
            } catch HiveError.failue {
                XCTFail()
            } catch {
                XCTFail()
            }
        }
        self.wait(for: [lock], timeout: 100.0)
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
*/
