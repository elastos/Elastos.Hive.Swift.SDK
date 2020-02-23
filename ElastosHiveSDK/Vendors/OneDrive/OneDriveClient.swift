import Foundation

private let nullValue: Void = Void()

class OneDriveClientHandle: HiveClientHandle, FilesProtocol, KeyValuesProtocol {
    var authenticator: Authenticator
    var authHelper: OneDriveAuthHelper
    
    init(_ clientOptions: HiveClientOptions) {
        let options = clientOptions as! OneDriveClientOptions
        authHelper = OneDriveAuthHelper(options.clientId,
                                        options.scope,
                                        options.redirectUrl,
                                        options.storePath)
        authenticator = options.authenicator!
    }

    public override func connect() throws {
        _ = authHelper.connectAsync(authenticator: authenticator)
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
                return self.doPutData(data, fileName)
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
        return HivePromise<Void>{ resolver in
            _ = self.authHelper.checkValid().then { _ -> HivePromise<Void> in
                return self.doPutDataFromFile(fileHandle, fileName)
            }.done{ _ in
                handler.didSucceed(nullValue)
                resolver.fulfill(nullValue)
            }.catch{ error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }

    func putDataFromInputStream(_ input: InputStream, asRemoteFile fileName: String) -> HivePromise<Void> {
        return putDataFromInputStream(input, asRemoteFile: fileName, handler: HiveCallback<Void>())
    }

    func putDataFromInputStream(_ input: InputStream, asRemoteFile fileName: String, handler: HiveCallback<Void>) -> HivePromise<Void> {
        // TODO:
        return HivePromise<Void>(error: HiveError.failue(des: "Not implemented"))
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
                return self.doGetData(fileName)
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
        return HivePromise<UInt64> { resolver in
            _ = self.authHelper.checkValid().then { _ -> HivePromise<Void> in
                return self.doGetDataToTargetFile(fileName, targetFile)
            }.done{ _ in
                // TOOD:
                handler.didSucceed(0)
                resolver.fulfill(0)
            }.catch{ error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }

    func getDataToOutputStream(fromRemoteFile fileName: String, output: OutputStream) -> HivePromise<UInt64> {
        return getDataToOutputStream(fromRemoteFile: fileName, output: output, handler: HiveCallback<UInt64>())
    }

    func getDataToOutputStream(fromRemoteFile: String, output: OutputStream, handler: HiveCallback<UInt64>) -> HivePromise<UInt64> {
        return HivePromise<UInt64>(error: HiveError.failue(des: "Not implemented"))
    }

    public func deleteRemoteFile(_ fileName: String) -> HivePromise<Void> {
        return deleteRemoteFile(fileName, handler: HiveCallback<Void>())
    }

    public func deleteRemoteFile(_ fileName: String, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>{ resolver in
            _ = self.authHelper.checkValid().then { _ -> HivePromise<Void> in
                return self.doDeleteRemoteFile(fileName)
            }.done{ _ in
                handler.didSucceed(nullValue)
                resolver.fulfill(nullValue)
            }.catch{ error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }

    func listRemoteFiles() -> HivePromise<Array<String>> {
        return listRemoteFiles(handler: HiveCallback<Array<String>>())
    }

    func listRemoteFiles(handler: HiveCallback<Array<String>>) -> Promise<Array<String>> {
        // TODO:
        return HivePromise<Array<String>>(error: HiveError.failue(des: "Not implemented"))
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
            _ = self.authHelper.checkValid().then{ _ -> HivePromise<Void> in
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
    
    private func doPutString(_ data: String, _ remoteFile: String) -> HivePromise<Void> {
        let url = OneDriveURL(remoteFile).write()
        let header = Header.init(authHelper).plain_headers()
        let data = data.data(using: .utf8)
        return OneDriveAPIs.uploadWriteData(data: data!, to: url, headers: header, self.authHelper)
    }
    
    private func doPutData(_ data: Data, _ remoteFile: String) -> HivePromise<Void> {
        let url = OneDriveURL(remoteFile).write()
        let header = Header.init(authHelper).plain_headers()
        return OneDriveAPIs.uploadWriteData(data: data, to: url, headers: header, self.authHelper)
    }
    
    private func doPutDataFromFile(_ fileHandle: FileHandle, _ remoteFile: String) -> HivePromise<Void> {
        fileHandle.seekToEndOfFile()
        return doPutData(fileHandle.readDataToEndOfFile(), remoteFile)
    }

    private func doGetFileSize(_ remoteFile: String) -> HivePromise<UInt64> {
        return HivePromise<UInt64> { resolver in
            let url = OneDriveURL(remoteFile).dirAndFileInfo()
            let header = Header(self.authHelper).plain_headers()

            OneDriveAPIs.request(url: url, headers: header, self.authHelper)
                .done { json in
                    resolver.fulfill(json["size"].uInt64Value)
                }.catch { error in
                    resolver.reject(error)
                }
        }
    }
    
    private func doGetString(_ remoteFile: String) -> HivePromise<String> {
        return HivePromise<String> { resolver in
            let url = OneDriveURL(remoteFile).read()
            let header = Header(self.authHelper).plain_headers()

            OneDriveAPIs.getRemoteFile(url: url, headers: header, authHelper: self.authHelper)
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
            let url = OneDriveURL(remoteFile).read()
            let header = Header(self.authHelper).plain_headers()

            OneDriveAPIs.getRemoteFile(url: url, headers: header, authHelper: self.authHelper)
                .done { jsonData in
                    resolver.fulfill(jsonData)
                }.catch { error in
                    resolver.reject(error)
                }
        }
    }
    
    private func doGetDataToTargetFile(_ remoteFile: String, _ targetFile: FileHandle) -> HivePromise<Void> {
        return HivePromise<Void> { resolver in
            let url = OneDriveURL(remoteFile).read()
            let header = Header(self.authHelper).plain_headers()

            OneDriveAPIs.getRemoteFile(url: url, headers: header, authHelper: self.authHelper)
                .done { jsonData in
                    targetFile.write(jsonData)
                    resolver.fulfill(Void())
                }.catch { error in
                    resolver.reject(error)
                }
        }
    }
    
    private func doDeleteRemoteFile(_ remoteFile: String) -> HivePromise<Void> {
        return HivePromise<Void>{ resolver in
            let url = OneDriveURL(remoteFile).deleteItem()
            let header = Header(self.authHelper).json_Headers()

            OneDriveAPIs.request(url: url, method: .delete, headers: header, self.authHelper)
                .done { json in
                    resolver.fulfill(Void())
                }.catch { error in
                    resolver.reject(error)
                }
        }
    }
    
    private func doPutValue(_ aValue: String, _ key: String) -> HivePromise<Void> {
        return doPutValue(aValue.data(using: .utf8)!, key)
    }

    private func doPutValue(_ aValue: Data, _ key: String) -> HivePromise<Void> {
        return HivePromise<Void>{ resolver in
            _ = doGetData(key).then { originData -> HivePromise<Void> in
                let valueBytes = self.dataToByteArray(data: aValue)
                let mergeBytes: [UInt8] = self.mergeLengthAndData(data: valueBytes)
                let originBytes: [UInt8] = self.dataToByteArray(data: originData)
                let finalBytes = self.mergeData(bytes1: originBytes, bytes2: mergeBytes)
                let finalData = self.byteArrayToData(bytes: finalBytes)
                let key = KEYVALUES_ROOT_PATH + key
                return self.doPutData(finalData, key)
            }
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
            _ = doDeleteRemoteFile(forKey).then { _ -> HivePromise<Void> in
                let dataBytes = self.dataToByteArray(data: newValue)
                let finalBytes = self.mergeLengthAndData(data: dataBytes)
                let data = self.byteArrayToData(bytes: finalBytes)
                return self.doPutValue(data, KEYVALUES_ROOT_PATH + forKey)
            }
        }
    }
    
    private func doValues(_ ofKey: String) -> HivePromise<[Data]> {
        return HivePromise<[Data]>{ resolver in
            doGetData(KEYVALUES_ROOT_PATH + ofKey).done { jsonData in
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
    
    private func do_deleteValues(forKey: String) -> HivePromise<Void> {
        return doDeleteRemoteFile(KEYVALUES_ROOT_PATH + forKey)
    }
}
