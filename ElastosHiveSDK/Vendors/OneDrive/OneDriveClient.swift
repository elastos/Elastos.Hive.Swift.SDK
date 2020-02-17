import Foundation

class OneDriveClientHandle: HiveClientHandle, FilesProtocol, KeyValuesProtocol {
    var authenticator: Authenticator
    var authHelper: OneDriveAuthHelper
    
    init(_ options: HiveClientOptions) {
        let oneDriveOptions: OneDriveClientOptions = options as! OneDriveClientOptions
        authHelper = OneDriveAuthHelper(oneDriveOptions.clientId!, oneDriveOptions.scope, oneDriveOptions.redirectUrl!, oneDriveOptions.storePath!)
        authenticator = oneDriveOptions.authenicator!
    }

    public override func connect() throws {
        _ = authHelper.loginAsync(authenticator)
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

    public func putString(_ data: String, asRemoteFile: String) -> HivePromise<Void> {
        putString(data, asRemoteFile: asRemoteFile, handler: HiveCallback<Void>())
    }

    public func putString(_ data: String, asRemoteFile: String, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>{ resolver in
            self.authHelper.checkExpired().then { _ -> HivePromise<Void> in
                return self.do_putString(data: data, asRemoteFile: asRemoteFile)
            }.done { _ in
                handler.didSucceed(Void())
                resolver.fulfill(Void())
            }.catch { error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }

    public func putData(_ data: Data, asRemoteFile: String) -> HivePromise<Void> {
        return putData(data, asRemoteFile: asRemoteFile, handler: HiveCallback<Void>())
    }

    public func putData(_ data: Data, asRemoteFile: String, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>{ resolver in
           _ = self.authHelper.checkExpired().then { _ -> HivePromise<Void> in
            return self.do_putData(data: data, asRemoteFile: asRemoteFile)
            }.done { _ in
                handler.didSucceed(Void())
                resolver.fulfill(Void())
            }.catch { error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }

    public func putDataFromFile(_ fileHandle: FileHandle, asRemoteFile: String) -> HivePromise<Void> {
        return putDataFromFile(fileHandle, asRemoteFile: asRemoteFile, handler: HiveCallback<Void>())
    }

    public func putDataFromFile(_ fileHandle: FileHandle, asRemoteFile: String, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>{ resolver in
            _ = self.authHelper.checkExpired().then{ _ -> HivePromise<Void> in
                return self.do_putDataFromFile(fileHandle: fileHandle, asRemoteFile: asRemoteFile)
            }.done{ _ in
                handler.didSucceed(Void())
                resolver.fulfill(Void())
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
            _ = self.authHelper.checkExpired().then{ _ -> HivePromise<UInt64> in
                return self.do_sizeofRemoteFile(fileName: fileName)
            }.done{ size in
                handler.didSucceed(size)
                resolver.fulfill(size)
            }.catch{ error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }

    public func getString(fromRemoteFile: String) -> HivePromise<String> {
        return getString(fromRemoteFile: fromRemoteFile, handler: HiveCallback<String>())
    }

    public func getString(fromRemoteFile: String, handler: HiveCallback<String>) -> HivePromise<String> {
        return HivePromise<String>{ resolver in
            _ = self.authHelper.checkExpired().then { _ -> HivePromise<String> in
                return self.do_getString(fromRemoteFile: fromRemoteFile)
            }.done { string in
                handler.didSucceed(string)
                resolver.fulfill(string)
            }.catch { error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }

    public func getData(fromRemoteFile: String) -> HivePromise<Data> {
        return getData(fromRemoteFile: fromRemoteFile, handler: HiveCallback<Data>())
    }

    public func getData(fromRemoteFile: String, handler: HiveCallback<Data>) -> HivePromise<Data> {
        return HivePromise<Data>{ resolver in
            _ = self.authHelper.checkExpired().then{ _ -> HivePromise<Data> in
                return self.do_getData(fromRemoteFile: fromRemoteFile)
            }.done{ data in
                handler.didSucceed(data)
                resolver.fulfill(data)
            }.catch{ error in
                handler.runError(error as! HiveError)
                resolver.reject(error)
            }
        }
    }

    public func getDataToTargetFile(fromRemoteFile: String, targetFile: FileHandle) -> HivePromise<Void> {
        return getDataToTargetFile(fromRemoteFile: fromRemoteFile, targetFile: targetFile, handler: HiveCallback<Void>())
    }

    public func getDataToTargetFile(fromRemoteFile: String, targetFile: FileHandle, handler: HiveCallback<Void>) -> HivePromise<Void> {
        return HivePromise<Void>{ resolver in
            _ = self.authHelper.checkExpired().then{ _ -> HivePromise<Void> in
                return self.do_getDataToTargetFile(fromRemoteFile: fromRemoteFile, targetFile: targetFile)
            }.done{ _ in
                handler.didSucceed(Void())
                resolver.fulfill(Void())
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
            _ = self.authHelper.checkExpired().then{ _ -> HivePromise<Void> in
                return self.do_deleteRemoteFile(fileName: fileName)
            }.done{ _ in
                handler.didSucceed(Void())
                resolver.fulfill(Void())
            }.catch{ error in
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
            _ = self.authHelper.checkExpired().then{ _ -> HivePromise<Void> in
                return self.do_putValue(aValue: aValue, forKey: forKey)
            }.done{ _ in
                handler.didSucceed(Void())
                resolver.fulfill(Void())
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
            _ = self.authHelper.checkExpired().then{ _ -> HivePromise<Void> in
                return self.do_putValue(aValue: aValue, forKey: forKey)
            }.done{ _ in
                handler.didSucceed(Void())
                resolver.fulfill(Void())
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
            _ = self.authHelper.checkExpired().then{ _ -> HivePromise<Void> in
                return self.do_setValue(newValue: newValue, forKey: forKey)
            }.done{ _ in
                handler.didSucceed(Void())
                resolver.fulfill(Void())
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
            _ = self.authHelper.checkExpired().then{ _ -> HivePromise<Void> in
                return self.do_setValue(newValue: newValue, forKey: forKey)
            }.done{ _ in
                handler.didSucceed(Void())
                resolver.fulfill(Void())
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
        return HivePromise<[Data]>{ resolver in
            _ = self.authHelper.checkExpired().then{ _ -> HivePromise<[Data]> in
                return self.do_values(ofKey: ofKey)
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
        return HivePromise<Void>{ resolver in
            _ = self.authHelper.checkExpired().then{ _ -> HivePromise<Void> in
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
    
    private func do_putString(data: String, asRemoteFile: String) -> HivePromise<Void> {
        let url: String = URLUtils(asRemoteFile).write()
        let header = Header.init(authHelper).plain_headers()
        let data = data.data(using: .utf8)
        return OneDriveAPIs.uploadWriteData(data: data!, to: url, headers: header, self.authHelper)
    }
    
    private func do_putData(data: Data, asRemoteFile: String) -> HivePromise<Void> {
        let url: String = URLUtils(asRemoteFile).write()
        let header = Header.init(authHelper).plain_headers()
        return OneDriveAPIs.uploadWriteData(data: data, to: url, headers: header, self.authHelper)
    }
    
    private func do_putDataFromFile(fileHandle: FileHandle, asRemoteFile: String) -> HivePromise<Void> {
        fileHandle.seekToEndOfFile()
        let data = fileHandle.readDataToEndOfFile()
        return do_putData(data: data, asRemoteFile: asRemoteFile)
    }

    private func do_sizeofRemoteFile(fileName: String) -> HivePromise<UInt64> {
        return HivePromise<UInt64>{ resolver in
            let url: String = URLUtils(fileName).dirAndFileInfo()
            let header = Header(self.authHelper).plain_headers()
            OneDriveAPIs.request(url: url, headers: header, self.authHelper).done { json in
                let size = json["size"].uInt64Value
                resolver.fulfill(size)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
    
    private func do_getString(fromRemoteFile: String) -> HivePromise<String> {
        return HivePromise<String>{ resolver in
            let url = URLUtils(fromRemoteFile).read()
            let header = Header(self.authHelper).plain_headers()
            OneDriveAPIs.getRemoteFile(url: url, headers: header, authHelper: self.authHelper)
                .done { jsonData in
                    let string = String(data: jsonData, encoding: .utf8) ?? ""
                    resolver.fulfill(string)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    private func do_getData(fromRemoteFile: String) -> HivePromise<Data> {
        return HivePromise<Data>{ resolver in
            let url = URLUtils(fromRemoteFile).read()
            let header = Header(self.authHelper).plain_headers()
            OneDriveAPIs.getRemoteFile(url: url, headers: header, authHelper: self.authHelper)
                .done { jsonData in
                    resolver.fulfill(jsonData)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
    
    private func do_getDataToTargetFile(fromRemoteFile: String, targetFile: FileHandle) -> HivePromise<Void> {
        
        return HivePromise<Void>{ resolver in
            let url = URLUtils(fromRemoteFile).read()
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
    
    private func do_deleteRemoteFile(fileName: String) -> HivePromise<Void> {
        return HivePromise<Void>{ resolver in
            let url = URLUtils(fileName).deleteItem()
            let header = Header(self.authHelper).json_Headers()
            OneDriveAPIs.request(url: url, method: .delete, headers: header, self.authHelper)
            .done { json in
                resolver.fulfill(Void())
            }.catch { error in
                resolver.reject(error)
            }
        }
    }
    
    private func do_putValue(aValue: String, forKey: String) -> HivePromise<Void> {
        let data = aValue.data(using: .utf8)!
        return do_putValue(aValue: data, forKey: forKey)
    }

    private func do_putValue(aValue: Data, forKey: String) -> HivePromise<Void> {
        return HivePromise<Void>{ resolver in
            _ = do_getData(fromRemoteFile: forKey).then { originData -> HivePromise<Void> in
                let valueBytes = self.dataToByteArray(data: aValue)
                let mergeBytes: [UInt8] = self.mergeLengthAndData(data: valueBytes)
                let originBytes: [UInt8] = self.dataToByteArray(data: originData)
                let finalBytes = self.mergeData(bytes1: originBytes, bytes2: mergeBytes)
                let finalData = self.byteArrayToData(bytes: finalBytes)
                return self.do_putData(data: finalData, asRemoteFile: forKey)
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
    
    private func do_setValue(newValue: String, forKey: String) -> HivePromise<Void> {
        let data = newValue.data(using: .utf8)!
        return do_setValue(newValue: data, forKey: forKey)
    }
    
    private func do_setValue(newValue: Data, forKey: String) -> HivePromise<Void> {
        return HivePromise<Void>{ resolver in
            _ = do_deleteRemoteFile(fileName: forKey).then { _ -> HivePromise<Void> in
                let dataBytes = self.dataToByteArray(data: newValue)
                let finalBytes = self.mergeLengthAndData(data: dataBytes)
                let data = self.byteArrayToData(bytes: finalBytes)
                return self.do_putValue(aValue: data, forKey: forKey)
            }
        }
    }
    
    private func do_values(ofKey: String) -> HivePromise<[Data]> {
        return HivePromise<[Data]>{ resolver in
            do_getData(fromRemoteFile: ofKey).done { jsonData in
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
        return do_deleteRemoteFile(fileName: forKey)
    }
}
