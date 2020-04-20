import XCTest
@testable import ElastosHiveSDK

class oneDriveKeyValuesProtocolTest: XCTestCase {
    private let CLIENT_ID = "afd3d647-a8b7-4723-bf9d-1b832f43b881"
    private let REDIRECT_URL = "http://localhost:12345"
    private let STORE_PATH = "\(NSHomeDirectory())/Library/Caches/onedrive"
    
    private var client: HiveClientHandle?
    private var keyValuesProtocol: KeyValuesProtocol?
    
    private let stringValue = "test string value"
    private let dataValue = "test data value".data(using: .utf8)
    private let setValue = "set data value".data(using: .utf8)
    
    private let strKey = "strKey111"
    private let dataKey = "dataKey"
    
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
    
    func test_01_PutValue() {
        let lock = XCTestExpectation(description: ".")
        _ = keyValuesProtocol!.putValue(stringValue, forKey: strKey).done{ _ in
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_01_PutValueHandle() {
        let lock = XCTestExpectation(description: ".")
        let handle: TestResultHandler = TestResultHandler({ (result: Void) in
            lock.fulfill()
        }) { (error) in
            XCTFail()
            lock.fulfill()
        }
        _ = keyValuesProtocol!.putValue(stringValue, forKey: strKey, handler: handle)
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_02_PutValue() {
        let lock = XCTestExpectation(description: ".")
        _ = keyValuesProtocol!.putValue(stringValue, forKey: strKey).done{ _ in
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_02_PutValueHandle() {
        let lock = XCTestExpectation(description: ".")
        let handle: TestResultHandler = TestResultHandler({ (result: Void) in
            lock.fulfill()
        }) { (error) in
            XCTFail()
            lock.fulfill()
        }
        _ = keyValuesProtocol!.putValue(stringValue, forKey: strKey, handler: handle)
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_03_PutData2() {
        let lock = XCTestExpectation(description: ".")
        _ = keyValuesProtocol!.putValue(dataValue!, forKey: dataKey).done{ _ in
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_03_PutData2Handle() {
        let lock = XCTestExpectation(description: ".")
        let handle: TestResultHandler = TestResultHandler({ (result: Void) in
            lock.fulfill()
        }) { (error) in
            XCTFail()
            lock.fulfill()
        }
        _ = keyValuesProtocol!.putValue(dataValue!, forKey: dataKey, handler: handle)
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_04_SetValue3() {
        let lock = XCTestExpectation(description: ".")
        _ = keyValuesProtocol!.setValue(setValue!, forKey: dataKey).done{ _ in
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_04_SetValue3Handle() {
        let lock = XCTestExpectation(description: ".")
        let handle: TestResultHandler = TestResultHandler({ (result: Void) in
            lock.fulfill()
        }) { (error) in
            XCTFail()
            lock.fulfill()
        }
        _ = keyValuesProtocol!.setValue(setValue!, forKey: dataKey, handler: handle)
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_05_Values() {
        let lock = XCTestExpectation(description: ".")
        _ = keyValuesProtocol!.values(ofKey: strKey).done{ list in
            XCTAssertNotEqual(1, list.count)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_remote_noKey_Values() {
        let lock = XCTestExpectation(description: ".")
        _ = keyValuesProtocol!.values(ofKey: "test_remote_noKey_Values").done{ list in
            XCTFail()
            lock.fulfill()
        }.catch{ error in
            if HiveError.description(error as! HiveError) == "Item does not exist"{
                XCTAssertTrue(true)
            }
            else {
                XCTFail()
            }
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_05_ValuesHandle() {
        let lock = XCTestExpectation(description: ".")
        let handle: TestResultHandler = TestResultHandler({ (result: [Data]) in
            XCTAssertNotEqual(1, result.count)
            lock.fulfill()
        }) { (error) in
            XCTFail()
            lock.fulfill()
        }
        _ = keyValuesProtocol!.values(ofKey: strKey, handler: handle)
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_06_DeleteValues() {
        let lock = XCTestExpectation(description: ".")
        _ = keyValuesProtocol!.deleteValues(forKey: dataKey).done{ _ in
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func test_06_DeleteValuesHandle() {
        let lock = XCTestExpectation(description: ".")
        let handle: TestResultHandler = TestResultHandler({ (result: Void) in
            lock.fulfill()
        }) { (error) in
            XCTFail()
            lock.fulfill()
        }
        _ = keyValuesProtocol!.deleteValues(forKey: strKey, handler: handle)
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
            
            let lock = XCTestExpectation(description: "wait for test connect.")
            let globalQueue = DispatchQueue.global()
            globalQueue.async {
                do {
                    try self.client?.connect()
                    XCTAssertTrue(self.client!.isConnected())
                    lock.fulfill()
                } catch HiveError.failue {
                    XCTFail()
                    lock.fulfill()
                } catch {
                    XCTFail()
                    lock.fulfill()
                }
            }
            self.wait(for: [lock], timeout: 100.0)
            //            try client?.connect()
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
