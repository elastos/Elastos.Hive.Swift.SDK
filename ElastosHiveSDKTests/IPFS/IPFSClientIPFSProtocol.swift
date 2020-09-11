import XCTest
@testable import ElastosHiveSDK
/*
class IPFSClientIFPSProtocolTest: XCTestCase {
    private let STORE_PATH = "fakePath"
    
    private var client: HiveClientHandle?
    private var ipfsProtocol: IPFSProtocol?
    private let localName = "testHello"
    private let remoteStringContent = "testHello"
    private let remoteDataContent = "this is data.".data(using: .utf8)
    private let IPADDRS: [String] = ["52.83.165.233", "52.83.238.247", "3.133.166.156", "13.59.79.222", "3.133.71.168"]
    private let cid = "QmaY6wjwnybJgd5F4FD6pPL6h9vjXrGv2BJbxxUC1ojUbQ"
    private let path = "\(NSHomeDirectory())/Library/Caches/ipfs"
    
    func testPutString() {
        let lock = XCTestExpectation(description: "testPutString")
        _ = ipfsProtocol?.putString(remoteStringContent).done{ hash in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func testPutStringHandle() {
        let lock = XCTestExpectation(description: "")
        let handle: TestResultHandler = TestResultHandler({ (result: Hash) in
            XCTAssertTrue(true)
            lock.fulfill()
        }) { (error) in
            XCTFail()
            lock.fulfill()
        }
        _ = ipfsProtocol?.putString(remoteStringContent, handler: handle)
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func testPutData() {
        let lock = XCTestExpectation(description: "")
        _ = ipfsProtocol?.putData(remoteDataContent!).done{ hash in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func testPutDataHandle() {
        let lock = XCTestExpectation(description: "")
        let handle: TestResultHandler = TestResultHandler({ (result: Hash) in
            XCTAssertTrue(true)
            lock.fulfill()
        }) { (error) in
            XCTFail()
            lock.fulfill()
        }
        _ = ipfsProtocol?.putData(remoteDataContent!, handler: handle)
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func testPutDataFromFile() {
        let lock = XCTestExpectation(description: "")
        let fileManger = FileManager.default
        let path = "\(NSHomeDirectory())/Library/Caches/\(localName)"
        if !fileManger.fileExists(atPath: path) {
            fileManger.createFile(atPath: path, contents: nil, attributes: nil)
        }
        let fileHndle: FileHandle = FileHandle(forUpdatingAtPath: path)!
        fileHndle.write(remoteDataContent!)
        let readerHndle = FileHandle(forReadingAtPath: path)
        readerHndle?.seek(toFileOffset: 0)
        _ = ipfsProtocol?.putDataFromFile(readerHndle!).done{ hash in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func testPutDataFromFileHandle() {
        let lock = XCTestExpectation(description: "")
        let handle: TestResultHandler = TestResultHandler({ (result: Hash) in
            XCTAssertTrue(true)
            lock.fulfill()
        }) { (error) in
            XCTFail()
            lock.fulfill()
        }
        let fileManger = FileManager.default
        let path = "\(NSHomeDirectory())/Library/Caches/\(localName)"
        if !fileManger.fileExists(atPath: path) {
            fileManger.createFile(atPath: path, contents: nil, attributes: nil)
        }
        let fileHndle: FileHandle = FileHandle(forUpdatingAtPath: path)!
        fileHndle.write(remoteDataContent!)
        let readerHndle = FileHandle(forReadingAtPath: path)
        readerHndle?.seek(toFileOffset: 0)
        _ = ipfsProtocol?.putDataFromFile(readerHndle!, handler: handle)
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func testPutDataFromInputStream() {
        let lock = XCTestExpectation(description: "")
        let input = InputStream.init(data: remoteDataContent!)
        _ = ipfsProtocol?.putDataFromInputStream(input).done{ hash in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func testPutDataFromInputStreamHandle() {
        let lock = XCTestExpectation(description: "")
        let handle: TestResultHandler = TestResultHandler({ (result: Hash) in
            XCTAssertTrue(true)
            lock.fulfill()
        }) { (error) in
            XCTFail()
            lock.fulfill()
        }
        let input = InputStream.init(data: remoteDataContent!)
        _ = ipfsProtocol?.putDataFromInputStream(input, handler: handle)
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func testPutSizeofRemoteFile() {
        let lock = XCTestExpectation(description: "")
        _ = ipfsProtocol?.sizeofRemoteFile(cid).done{ size in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func testPutSizeofRemoteFileHandle() {
        let lock = XCTestExpectation(description: "")
        let handle: TestResultHandler = TestResultHandler({ (result: UInt64) in
            XCTAssertTrue(true)
            lock.fulfill()
        }) { (error) in
            XCTFail()
            lock.fulfill()
        }
        _ = ipfsProtocol?.sizeofRemoteFile(cid, handler: handle)
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func testGetString() {
        let lock = XCTestExpectation(description: "")
        _ = ipfsProtocol?.getString(fromRemoteFile: Hash(cid)).done{ str in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func testGetStringHandle() {
        let lock = XCTestExpectation(description: "")
        let handle: TestResultHandler = TestResultHandler({ (result: String) in
            XCTAssertTrue(true)
            lock.fulfill()
        }) { (error) in
            XCTFail()
            lock.fulfill()
        }
        _ = ipfsProtocol?.getString(fromRemoteFile: Hash(cid), handler: handle)
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func testGetData() {
        let lock = XCTestExpectation(description: "")
        _ = ipfsProtocol?.getData(fromRemoteFile: Hash(cid)).done{ data in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func testGetDataHandle() {
        let lock = XCTestExpectation(description: "")
        let handle: TestResultHandler = TestResultHandler({ (result: Data) in
            XCTAssertTrue(true)
            lock.fulfill()
        }) { (error) in
            XCTFail()
            lock.fulfill()
        }
        _ = ipfsProtocol?.getData(fromRemoteFile: Hash(cid), handler: handle)
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func testGetDataToTargetFile() {
        let lock = XCTestExpectation(description: "")
        let fileManger = FileManager.default
        let path = "\(NSHomeDirectory())/Library/Caches/testGetDataToTargetFile"
        if !fileManger.fileExists(atPath: path) {
            fileManger.createFile(atPath: path, contents: nil, attributes: nil)
        }
        let fileHndle: FileHandle = FileHandle(forWritingAtPath: path)!
        _ = ipfsProtocol?.getDataToTargetFile(fromRemoteFile: Hash(cid), targetFile: fileHndle).done{ size in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func testGetDataToTargetFileHandle() {
        let lock = XCTestExpectation(description: "")
        let handle: TestResultHandler = TestResultHandler({ (result: Void) in
            XCTAssertTrue(true)
            lock.fulfill()
        }) { (error) in
            XCTFail()
            lock.fulfill()
        }
        let fileManger = FileManager.default
        let path = "\(NSHomeDirectory())/Library/Caches/testGetDataToTargetFile"
        if !fileManger.fileExists(atPath: path) {
            fileManger.createFile(atPath: path, contents: nil, attributes: nil)
        }
        let fileHndle: FileHandle = FileHandle(forWritingAtPath: path)!
        _ = ipfsProtocol?.getDataToTargetFile(fromRemoteFile: Hash(cid), targetFile: fileHndle, handler: handle)
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func testGetDataToOutputStream() {
        let lock = XCTestExpectation(description: "")
        let output = OutputStream(toMemory: ())
        _ = ipfsProtocol?.getDataToOutputStream(fromRemoteFile: Hash(cid), output: output).done{ size in
            XCTAssertTrue(true)
            lock.fulfill()
        }.catch{ error in
            XCTFail()
            lock.fulfill()
        }
        self.wait(for: [lock], timeout: 100.0)
    }
    
    func testGetDataToOutputStreamHandle() {
        let lock = XCTestExpectation(description: "")
        let handle: TestResultHandler = TestResultHandler({ (result: Void) in
            XCTAssertTrue(true)
            lock.fulfill()
        }) { (error) in
            XCTFail()
            lock.fulfill()
        }
        let output = OutputStream(toMemory: ())
        _ = ipfsProtocol?.getDataToOutputStream(fromRemoteFile: Hash(cid), output: output, handler: handle)
        self.wait(for: [lock], timeout: 100.0)
    }
    
    override func setUp() {
        do {
            let options = try IPFSClientOptionsBuilder()
                .appendRpcNode(IPFSRpcNode(IPADDRS[0], 5001))
                .appendRpcNode(IPFSRpcNode(IPADDRS[1], 5001))
                .appendRpcNode(IPFSRpcNode(IPADDRS[2], 5001))
                .appendRpcNode(IPFSRpcNode(IPADDRS[3], 5001))
                .appendRpcNode(IPFSRpcNode(IPADDRS[4], 5001))
                .withStorePath(using: STORE_PATH)
                .build()
            
            XCTAssertNotNil(options)
            XCTAssertTrue(options.rpcNodes.count > 0)
            
            client = try HiveClientHandle.createInstance(withOptions: options)
            XCTAssertNotNil(client)
            XCTAssertFalse(client!.isConnected())
            
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
            XCTAssertTrue(client!.isConnected())
            
            ipfsProtocol = client!.asIPFS()
            XCTAssertNotNil(ipfsProtocol)
            
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
*/
