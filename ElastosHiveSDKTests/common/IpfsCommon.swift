
import XCTest
import ElastosHiveSDK

let addrs = [
    "http://52.83.119.110:9095",
    "http://52.83.159.189:9095",
    "http://3.16.202.140:9095",
    "http://18.217.147.205:9095",
    "http://18.219.53.133:9095"]
class IpfsCommon: XCTestCase, Authenticator {
    func requestAuthentication(_ requestURL: String) -> Bool {
        return true
    }
    let timeout: Double = 100.0
    
    func login(_ lock: XCTestExpectation, hiveClient: HiveClientHandle) {
        let globalQueue = DispatchQueue.global()
        globalQueue.async {
            do {
                _ = try hiveClient.login(self as Authenticator)
                lock.fulfill()
                XCTAssert(true)
            }catch {
                XCTFail()
                lock.fulfill()
            }
        }
        wait(for: [lock], timeout: timeout)
    }

    func logOut(_ lock: XCTestExpectation, hiveClient: HiveClientHandle) {
        let globalQueue = DispatchQueue.global()
        globalQueue.async {
            do{
                _ = try hiveClient.logout()
                lock.fulfill()
                XCTAssert(true)
            }catch{
                XCTFail()
                lock.fulfill()
            }
        }
        wait(for: [lock], timeout: timeout)
    }

    func creatDirectory(_ lock: XCTestExpectation, hiveClient: HiveClientHandle, _ timeTest: String) {
        hiveClient.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.createDirectory(withPath: "/ipfs_createD_\(timeTest)")
            }.done{ directory in
                XCTAssertNotNil(directory.directoryId)
                lock.fulfill()
            }.catch{ error in
                XCTFail()
                lock.fulfill()
        }
        wait(for: [lock], timeout: timeout)
    }

    func createFile(_ lock: XCTestExpectation, hiveClient: HiveClientHandle, _ timeTest: String) {
        hiveClient.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveFileHandle> in
                return drive.createFile(withPath: "/ipfs_createF_\(timeTest)")
            }.done{ file in
                XCTAssertNotNil(file.fileId)
                lock.fulfill()
            }.catch{ error in
                XCTFail()
                lock.fulfill()
        }
        wait(for: [lock], timeout: timeout)
    }

    func writeData(_ lock: XCTestExpectation, hiveClient: HiveClientHandle, _ timeTest: String) {
        // write
        let data = "ios test for write \(timeTest)".data(using: .utf8)
        var fl: HiveFileHandle?
        hiveClient.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveFileHandle> in
                return drive.fileHandle(atPath: "/ipfs_createF_\(timeTest)")
            }.then{ file -> HivePromise<Int32> in
                fl = file
                return file.writeData(withData: data!, 0)
            }.then{ length -> HivePromise<Void> in
                return (fl?.commitData())!
            }.done{ data in
                lock.fulfill()
            }.catch{ er in
                XCTFail()
                lock.fulfill()
        }
        wait(for: [lock], timeout: timeout)
    }

    func creatDirectoryWithName(_ lock: XCTestExpectation, hiveClient: HiveClientHandle, _ timeTest: String) {
        hiveClient.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }.then{ directory -> HivePromise<HiveDirectoryHandle> in
                return directory.createDirectory(withName: "ipfs_createD_\(timeTest)")
            }.done{ directory in
                XCTAssertNotNil(directory.directoryId)
                lock.fulfill()
            }.catch{ error in
                XCTFail()
                lock.fulfill()
        }
        wait(for: [lock], timeout: timeout)
    }

    func createFileWithName(_ lock: XCTestExpectation, hiveClient: HiveClientHandle, _ timeTest: String) {
        hiveClient.defaultDriveHandle()
            .then{ drive -> HivePromise<HiveDirectoryHandle> in
                return drive.rootDirectoryHandle()
            }.then{ directory -> HivePromise<HiveFileHandle> in
                directory.createFile(withName: "ipfs_createF_\(timeTest)")
            }.done{ file in
                XCTAssertNotNil(file)
                lock.fulfill()
            }.catch{ error in
                XCTFail()
                lock.fulfill()
        }
        wait(for: [lock], timeout: timeout)
    }
}
