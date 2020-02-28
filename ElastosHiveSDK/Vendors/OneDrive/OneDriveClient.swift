import Foundation

private let nullValue: Void = Void()

class OneDriveClientHandle: HiveClientHandle, FilesProtocol, KeyValuesProtocol {
    var authenticator: Authenticator
    var authHelper: OneDriveAuthHelper
    private var fileHandle: FileHandle?
    private var outputStream: OutputStream?
    
    init(_ clientOptions: HiveClientOptions) {
        let options = clientOptions as! OneDriveClientOptions
        authHelper = OneDriveAuthHelper(options.clientId,
                                        options.scope,
                                        options.redirectUrl,
                                        options.storePath)
        authenticator = options.authenicator!
    }
    
    public override func connect() throws {
        _ = try authHelper.connectAsync(authenticator: authenticator).wait()
    }
    
    public override func connectAsync() -> HivePromise<Void> {
        return connectAsync(handler: HiveCallback<Void>())
    }
    
    public override func connectAsync(handler: HiveCallback<Void>) -> HivePromise<Void> {
        return authHelper.connectAsync(authenticator: authenticator)
    }
    
    public override func disconnect() {
        authHelper.disconnect()
    }
    
    public override func isConnected() -> Bool {
        return authHelper.connectState
    }
    
    public override func asFiles() -> FilesProtocol? {
        return self as FilesProtocol
    }
    
    public override func asKeyValues() -> KeyValuesProtocol? {
        return self as KeyValuesProtocol
    }
    
    public func putString(_ data: String, asRemoteFile fileName: String) -> HivePromise<Void> {
        putString(data, asRemoteFile: fileName, handler: HiveCallback<Void>())
    }
    
    public func putString(_ data: String, asRemoteFile fileName: String, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>{ resolver in
            self.authHelper.checkValid().then { _ -> HivePromise<Void> in
                return self.doPutString(data, fileName)
            }.done { _ in
                handler.didSucceed(nullValue)
                resolver.fulfill(nullValue)
            }.catch { error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    public func putData(_ data: Data, asRemoteFile fileName: String) -> HivePromise<Void> {
        return putData(data, asRemoteFile: fileName, handler: HiveCallback<Void>())
    }
    
    public func putData(_ data: Data, asRemoteFile fileName: String, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>{ resolver in
            _ = self.authHelper.checkValid().then { _ -> HivePromise<Void> in
                return self.doPutData(data, OneDriveURL(forPath: fileName).write())
            }.done { _ in
                handler.didSucceed(nullValue)
                resolver.fulfill(nullValue)
            }.catch { error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    public func putDataFromFile(_ fileHandle: FileHandle, asRemoteFile fileName: String) -> HivePromise<Void> {
        return putDataFromFile(fileHandle, asRemoteFile: fileName, handler: HiveCallback<Void>())
    }
    
    public func putDataFromFile(_ fileHandle: FileHandle, asRemoteFile fileName: String, handler: HiveCallback<Void>) -> HivePromise<Void> {
        self.fileHandle = fileHandle
        return HivePromise<Void>{ resolver in
            _ = self.authHelper.checkValid().then { _ -> HivePromise<Void> in
                return self.doPutDataFromFile(self.fileHandle!, fileName)
            }.done{ _ in
                handler.didSucceed(nullValue)
                resolver.fulfill(nullValue)
            }.catch{ error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    public func putDataFromInputStream(_ input: InputStream, asRemoteFile fileName: String) -> HivePromise<Void> {
        return putDataFromInputStream(input, asRemoteFile: fileName, handler: HiveCallback<Void>())
    }
    
    public func putDataFromInputStream(_ input: InputStream, asRemoteFile fileName: String, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>{ resolver in
            _ = self.authHelper.checkValid().then { _ -> HivePromise<Void> in
                return try self.doPutDataFromInputStream(input, asRemoteFile: fileName)
            }.done{ _ in
                handler.didSucceed(nullValue)
                resolver.fulfill(nullValue)
            }.catch{ error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    public func sizeofRemoteFile(_ fileName: String) -> HivePromise<UInt64> {
        return sizeofRemoteFile(fileName, handler: HiveCallback<UInt64>())
    }
    
    public func sizeofRemoteFile(_ fileName: String, handler: HiveCallback<UInt64>) -> HivePromise<UInt64> {
        return HivePromise<UInt64>{ resolver in
            _ = self.authHelper.checkValid().then { _ -> HivePromise<UInt64> in
                return self.doGetFileSize(fileName)
            }.done{ size in
                handler.didSucceed(size)
                resolver.fulfill(size)
            }.catch{ error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    public func getString(fromRemoteFile fileName: String) -> HivePromise<String> {
        return getString(fromRemoteFile: fileName, handler: HiveCallback<String>())
    }
    
    public func getString(fromRemoteFile fileName: String, handler: HiveCallback<String>) -> HivePromise<String> {
        return HivePromise<String>{ resolver in
            _ = self.authHelper.checkValid().then { _ -> HivePromise<String> in
                return self.doGetString(fileName)
            }.done { data in
                handler.didSucceed(data)
                resolver.fulfill(data)
            }.catch { error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    public func getData(fromRemoteFile fileName: String) -> HivePromise<Data> {
        return getData(fromRemoteFile: fileName, handler: HiveCallback<Data>())
    }
    
    public func getData(fromRemoteFile fileName: String, handler: HiveCallback<Data>) -> HivePromise<Data> {
        return HivePromise<Data>{ resolver in
            _ = self.authHelper.checkValid().then { _ -> HivePromise<Data> in
                return self.doGetData(OneDriveURL(forPath: fileName).read())
            }.done{ data in
                handler.didSucceed(data)
                resolver.fulfill(data)
            }.catch{ error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    public func getDataToTargetFile(fromRemoteFile fileName: String, targetFile: FileHandle) -> HivePromise<UInt64> {
        return getDataToTargetFile(fromRemoteFile: fileName, targetFile: targetFile, handler: HiveCallback<UInt64>())
    }
    
    public func getDataToTargetFile(fromRemoteFile fileName: String, targetFile: FileHandle, handler: HiveCallback<UInt64>) -> HivePromise<UInt64> {
        self.fileHandle = targetFile
        return HivePromise<UInt64> { resolver in
            _ = self.authHelper.checkValid().then { _ -> HivePromise<UInt64> in
                return self.doGetDataToTargetFile(fileName, self.fileHandle!)
            }.done{ size in
                handler.didSucceed(size)
                resolver.fulfill(size)
            }.catch{ error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    public func getDataToOutputStream(fromRemoteFile fileName: String, output: OutputStream) -> HivePromise<UInt64> {
        return getDataToOutputStream(fromRemoteFile: fileName, output: output, handler: HiveCallback<UInt64>())
    }
    
    public func getDataToOutputStream(fromRemoteFile: String, output: OutputStream, handler: HiveCallback<UInt64>) -> HivePromise<UInt64> {
        self.outputStream = output
        return HivePromise<UInt64> { resolver in
            _ = self.authHelper.checkValid().then{ _ -> HivePromise<Data> in
                return self.doGetDataToOutputStream(fromRemoteFile: fromRemoteFile)
            }.done{ data in
                // TODO: write
                //                let size = self.outputStream!.write(data: data)
                handler.didSucceed(UInt64(0))
                resolver.fulfill(UInt64(0))
            }.catch{ error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    public func deleteRemoteFile(_ fileName: String) -> HivePromise<Void> {
        return deleteRemoteFile(fileName, handler: HiveCallback<Void>())
    }
    
    public func deleteRemoteFile(_ fileName: String, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>{ resolver in
            _ = self.authHelper.checkValid().then { _ -> HivePromise<JSON> in
                return self.doDeleteRemoteFile(OneDriveURL(forPath: fileName).deleteItem())
            }.done{ _ in
                handler.didSucceed(nullValue)
                resolver.fulfill(nullValue)
            }.catch{ error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    public func listRemoteFiles() -> HivePromise<Array<String>> {
        return listRemoteFiles(handler: HiveCallback<Array<String>>())
    }
    
    public func listRemoteFiles(handler: HiveCallback<Array<String>>) -> Promise<Array<String>> {
        return HivePromise<Array<String>> { resolver in
            doListRemoteFiles().done { json in
                let arr = json["value"].arrayValue
                var list = [String]()
                arr.forEach { json in
                    let name = json["name"].stringValue
                    list.append(name)
                }
                handler.didSucceed(list)
                resolver.fulfill(list)
            }.catch { error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    public func putValue(_ aValue: String, forKey: String) -> HivePromise<Void> {
        return putValue(aValue, forKey: forKey,  handler: HiveCallback<Void>())
    }
    
    public func putValue(_ aValue: String, forKey: String, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>{ resolver in
            _ = self.authHelper.checkValid().then { _ -> HivePromise<Void> in
                return self.doPutValue(aValue, forKey)
            }.done{ _ in
                handler.didSucceed(nullValue)
                resolver.fulfill(nullValue)
            }.catch{ error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    public func putValue(_ aValue: Data, forKey: String) -> HivePromise<Void> {
        return putValue(aValue, forKey: forKey,  handler: HiveCallback<Void>())
    }
    
    public func putValue(_ aValue: Data, forKey: String, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>{ resolver in
            _ = self.authHelper.checkValid().then { _ -> HivePromise<Void> in
                return self.doPutValue(aValue, forKey)
            }.done{ _ in
                handler.didSucceed(nullValue)
                resolver.fulfill(nullValue)
            }.catch{ error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    public func setValue(_ newValue: String, forKey: String) -> HivePromise<Void> {
        return setValue(newValue, forKey: forKey, handler: HiveCallback<Void>())
    }
    
    public func setValue(_ newValue: String, forKey: String, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>{ resolver in
            _ = self.authHelper.checkValid().then{ _ -> HivePromise<Void> in
                return self.doSetValue(newValue, forKey)
            }.done{ _ in
                handler.didSucceed(nullValue)
                resolver.fulfill(nullValue)
            }.catch{ error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    public func setValue(_ newValue: Data, forKey: String) -> HivePromise<Void> {
        return setValue(newValue, forKey: forKey, handler:  HiveCallback<Void>())
    }
    
    public func setValue(_ newValue: Data, forKey: String, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>{ resolver in
            _ = self.authHelper.checkValid().then{ _ -> HivePromise<Void> in
                return self.doSetValue(newValue, forKey)
            }.done{ _ in
                handler.didSucceed(nullValue)
                resolver.fulfill(nullValue)
            }.catch{ error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    public func values(ofKey: String) -> HivePromise<[Data]> {
        return values(ofKey: ofKey, handler: HiveCallback<[Data]>())
    }
    
    public func values(ofKey: String, handler: HiveCallback<[Data]>) -> HivePromise<[Data]> {
        return HivePromise<[Data]> { resolver in
            _ = self.authHelper.checkValid().then{ _ -> HivePromise<[Data]> in
                return self.doValues(ofKey)
            }.done{ valueList in
                handler.didSucceed(valueList)
                resolver.fulfill(valueList)
            }.catch{ error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    public func deleteValues(forKey: String) -> HivePromise<Void> {
        return deleteValues(forKey: forKey, handler: HiveCallback<Void>())
    }
    
    public func deleteValues(forKey: String, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void> { resolver in
            _ = self.authHelper.checkValid().then{ _ -> HivePromise<JSON> in
                return self.do_deleteValues(forKey: forKey)
            }.done{ _ in
                handler.didSucceed(Void())
                resolver.fulfill(Void())
            }.catch{ error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }
    
    //    MARK:- private
    private func doPutString(_ data: String, _ remoteFile: String) -> HivePromise<Void> {
        let url = OneDriveURL(forPath: remoteFile).write()
        let header = Header.init(authHelper).plain_headers()
        let data = data.data(using: .utf8)
        return OneDriveAPIs.uploadWriteData(data: data!, to: url, headers: header)
    }
    
    private func doPutData(_ data: Data, _ remoteFile: String) -> HivePromise<Void> {
        let header = Header.init(authHelper).plain_headers()
        return OneDriveAPIs.uploadWriteData(data: data, to: remoteFile, headers: header)
    }
    
    private func doPutDataFromFile(_ fileHandle: FileHandle, _ remoteFile: String) -> HivePromise<Void> {
        return doPutData(fileHandle.readDataToEndOfFile(), OneDriveURL(forPath: remoteFile).write())
    }
    
    private func doGetFileSize(_ remoteFile: String) -> HivePromise<UInt64> {
        return HivePromise<UInt64> { resolver in
            let url = OneDriveURL(forPath: remoteFile).dirAndFileInfo()
            let header = Header(self.authHelper).plain_headers()
            
            OneDriveAPIs.request(url: url, headers: header)
                .done { json in
                    resolver.fulfill(json["size"].uInt64Value)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
    
    private func doGetString(_ remoteFile: String) -> HivePromise<String> {
        return HivePromise<String> { resolver in
            let url = OneDriveURL(forPath: remoteFile).read()
            let header = Header(self.authHelper).plain_headers()
            OneDriveAPIs.getRemoteFile(url: url, headers: header)
                .done { jsonData in
                    let data = String(data: jsonData, encoding: .utf8) ?? ""
                    resolver.fulfill(data)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
    
    private func doGetData(_ remoteFile: String) -> HivePromise<Data> {
        return HivePromise<Data> { resolver in
            let header = Header(self.authHelper).plain_headers()
            OneDriveAPIs.getRemoteFile(url: remoteFile, headers: header)
                .done { jsonData in
                    resolver.fulfill(jsonData)
            }.catch { error in
                if HiveError.description(error as! HiveError) == "Item does not exist"{
                    resolver.fulfill(Data())
                    return
                }
                resolver.reject(error)
            }
        }
    }
    
    private func doGetDataToTargetFile(_ remoteFile: String, _ targetFile: FileHandle) -> HivePromise<UInt64> {
        return HivePromise<UInt64> { resolver in
            let url = OneDriveURL(forPath: remoteFile).read()
            let header = Header(self.authHelper).plain_headers()
            
            OneDriveAPIs.getRemoteFile(url: url, headers: header)
                .done { jsonData in
                    targetFile.write(jsonData)
                    resolver.fulfill(UInt64(jsonData.count))
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
    
    private func doDeleteRemoteFile(_ remoteFile: String) -> HivePromise<JSON> {
        let header = Header(self.authHelper).json_Headers()
        return OneDriveAPIs.request(url: remoteFile, method: .delete, headers: header)
    }
    
    private func doPutValue(_ aValue: String, _ key: String) -> HivePromise<Void> {
        return doPutValue(aValue.data(using: .utf8)!, key)
    }
    
    private func doPutValue(_ aValue: Data, _ key: String) -> HivePromise<Void> {
        return doGetData(OneDriveURL(forKey: key).read()).then { originData -> HivePromise<Void> in
            let valueBytes = self.dataToByteArray(data: aValue)
            let mergeBytes: [UInt8] = self.mergeLengthAndData(data: valueBytes)
            let originBytes: [UInt8] = self.dataToByteArray(data: originData)
            let finalBytes = self.mergeData(bytes1: originBytes, bytes2: mergeBytes)
            let finalData = self.byteArrayToData(bytes: finalBytes)
            return self.doPutData(finalData, OneDriveURL(forKey: key).write())
        }
    }
    
    func mergeData(bytes1: [UInt8], bytes2: [UInt8]) -> [UInt8] {
        var tmp: [UInt8] = []
        tmp.append(contentsOf: bytes1)
        tmp.append(contentsOf: bytes2)
        return tmp
    }
    
    func mergeLengthAndData(data: [UInt8]) -> [UInt8] {
        let lengthByte: [UInt8] = intToByteArray(i: data.count)
        return mergeData(bytes1: lengthByte, bytes2: data)
    }
    
    func dataToByteArray(data : Data) -> [UInt8] {
        return [UInt8](data)
    }
    
    func byteArrayToData(bytes : [UInt8]) -> Data {
        return Data(bytes)
    }
    
    func intToByteArray(i : Int) -> [UInt8] {
        var result: [UInt8] = []
        result.append(UInt8((i >> 24) & 0xFF))
        result.append(UInt8((i >> 16) & 0xFF))
        result.append(UInt8((i >> 8) & 0xFF))
        result.append(UInt8(i & 0xFF))
        return result
    }
    
    func byteArrayToInt(bytes : [UInt8]) -> Int {
        var value: Int = 0
        for i in 0..<4 {
            let shift = (4 - 1 - i) * 8;
            value += (Int(bytes[i]) & 0x000000FF) << shift
        }
        return value
    }
    
    private func doSetValue(_ newValue: String, _ forKey: String) -> HivePromise<Void> {
        let data = newValue.data(using: .utf8)!
        return doSetValue(data, forKey)
    }
    
    private func doSetValue(_ newValue: Data, _ forKey: String) -> HivePromise<Void> {
        return HivePromise<Void>{ resolver in
            //TODO: remember check 
            let dataBytes = self.dataToByteArray(data: newValue)
            let finalBytes = self.mergeLengthAndData(data: dataBytes)
            let data = self.byteArrayToData(bytes: finalBytes)
            self.doPutValue(data, forKey)
                .done{ _ in
                    resolver.fulfill(Void())
            }.catch{ error in
                resolver.reject(error)
            }
        }
    }
    
    private func doValues(_ ofKey: String) -> HivePromise<[Data]> {
        return HivePromise<[Data]>{ resolver in
            doGetData(OneDriveURL(forKey: ofKey).read()).done { jsonData in
                let arrayList: Array<Data> = []
                let valueBytes = self.dataToByteArray(data: jsonData)
                let result = self.createValueResult(arrayList, valueBytes)
                resolver.fulfill(result)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
    
    private func createValueResult(_ arrayList: [Data], _ data: [UInt8]) -> [Data] {
        var arr = arrayList
        let total = data.count
        let dataLength = calcuLength(data)
        let strbytes = spliteBytes(data, dataLength)
        let strData = byteArrayToData(bytes: strbytes)
        arr.append(strData)
        let remainingDataLength = total - (dataLength + 4)
        if remainingDataLength <= 0 {
            return arr
        }
        let remainingData = [UInt8](data[(dataLength + 4)..<data.count])
        return createValueResult(arr, remainingData)
    }
    
    private func calcuLength(_ data: [UInt8]) -> Int {
        let tmp = [UInt8](data[0..<4])
        return byteArrayToInt(bytes: tmp)
    }
    
    private func spliteBytes(_ data: [UInt8], _ length: Int) -> [UInt8] {
        let end = length + 3
        let tmp = [UInt8](data[3..<end])
        return tmp
    }
    
    private func do_deleteValues(forKey: String) -> HivePromise<JSON> {
        return doDeleteRemoteFile(OneDriveURL(forKey: forKey).deleteItem())
    }
    
    private func doPutDataFromInputStream(_ input: InputStream, asRemoteFile fileName: String) throws -> HivePromise<Void> {
        var data = Data()
        input.open()
        
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        
        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: bufferSize)
            if read < 0 {
                //Stream error occured
                throw input.streamError!
            }
            else if read == 0 {
                //EOF
                break
            }
            data.append(buffer, count: read)
        }
        do{
            input.close()
        }
        do{
            buffer.deallocate()
        }
        return doPutData(data, OneDriveURL(forPath: fileName).write())
    }
    
    private func doGetDataToOutputStream(fromRemoteFile: String) -> HivePromise<Data> {
        return doGetData(OneDriveURL(forPath: fromRemoteFile).read())
    }
    
    private func doListRemoteFiles() -> HivePromise<JSON> {
        let url = OneDriveURL.children()
        let header = Header(self.authHelper).json_Headers()
        return OneDriveAPIs.request(url: url, headers: header)
    }
}
