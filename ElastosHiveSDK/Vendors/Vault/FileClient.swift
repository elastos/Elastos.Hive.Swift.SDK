/*
* Copyright (c) 2019 Elastos Foundation
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

import Foundation
private let remoteDataFromInputStreamContent = "this is test for DataFromInputStream".data(using: .utf8)
class FileClient: FilesProtocol {

    private var authHelper: VaultAuthHelper

    public init(_ authHelper: VaultAuthHelper) {
        self.authHelper = authHelper
    }

    func upload(_ path: String) -> HivePromise<InputStream> {
        return upload(path, handler: HiveCallback())
    }

    func upload(_ path: String, handler: HiveCallback<InputStream>) -> HivePromise<InputStream> {
        return authHelper.checkValid().then { _ -> HivePromise<InputStream> in
            return self.uploadImp(path, callback: handler)
        }
    }

    private func uploadImp(_ path: String, callback: HiveCallback<InputStream>) -> HivePromise<InputStream> {
        return HivePromise<InputStream> { resolver in
//            var inStream = InputStream()

            var data = Data()

            let inStream = InputStream.init(fileAtPath: "/Users/liaihong/Documents/Git/Elastos.NET.Hive.Swift.SDK_1/ElastosHiveSDKTests/Resources/test.txt")

            inStream!.open()
            let bufferSize = 1024
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)

            while inStream!.hasBytesAvailable {
                let read = inStream!.read(buffer, maxLength: bufferSize)
                if read < 0 {
//                    throw inStream?.streamError!
                } else if read == 0 {
                    //EOF
                    break
                }
                data.append(buffer, count: read)
            }

            print(String(data: data, encoding: String.Encoding.utf8) as Any)

//            let outStream = OutputStream.init(url: <#T##URL#>, append: <#T##Bool#>)

            let outputStream = OutputStream(toFileAtPath: path, append: false)
//            resolver.fulfill(inStream)
//            let url = VaultURL.sharedInstance.upload(path)
//            Alamofire.upload(inStream, to: url, method: .post, headers: Header(authHelper).headers()).responseData { responseData in
//                let re = String(data: responseData.data!, encoding: .utf8)
//                print(re)
//                print(re)
//            }
        }
    }
    /*
     private <T> CompletableFuture<T> uploadImp(String path, Class<T> resultType, Callback<T> callback) {

         return CompletableFuture.supplyAsync(() -> {

             HttpURLConnection httpURLConnection = null;
             try {
                 httpURLConnection = ConnectionManager.openURLConnection(path);
                 OutputStream rawOutputStream = httpURLConnection.getOutputStream();

                 if(null == rawOutputStream) return null;

                 UploadOutputStream outputStream = new UploadOutputStream(httpURLConnection, rawOutputStream);

                 if(resultType.isAssignableFrom(OutputStream.class)) {
                     callback.onSuccess((T) outputStream);
                     return (T) outputStream;
                 } else {
                     OutputStreamWriter outputStreamWriter = new OutputStreamWriter(outputStream);
                     callback.onSuccess((T) outputStreamWriter);
                     return (T) outputStreamWriter;
                 }
             } catch (Exception e) {
                 ResponseHelper.readConnection(httpURLConnection);
                 HiveException exception = new HiveException(e.getLocalizedMessage());
                 callback.onError(exception);
                 throw new CompletionException(exception);
             }
         });
     }
     */
    func download(_ path: String) -> HivePromise<OutputStream> {
        return download(path, handler: HiveCallback())
    }

    func download(_ path: String, handler: HiveCallback<OutputStream>) -> HivePromise<OutputStream> {
        return authHelper.checkValid().then { _ -> HivePromise<OutputStream> in
            return self.downloadImp(path, handler: handler)
        }
    }

    private func downloadImp<T>(_ remoteFile: String, handler: HiveCallback<T>) -> HivePromise<T> {
        return HivePromise<T> { resolver in
            //            resolver.fulfill(inStream)
            let url = VaultURL.sharedInstance.download(remoteFile)
            Alamofire.request(url, method: .get, headers: Header(authHelper).headers())
                .responseData { data_re in
                    let re = String(data: data_re.data!, encoding: .utf8)
                    print(re)
                    print(re)
            }
        }
    }

    func delete(_ path: String) -> HivePromise<Bool> {
        return delete(path, handler: HiveCallback())
    }

    func delete(_ path: String, handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.deleteImp(path, handler)
        }
    }

    private func deleteImp(_ remoteFile: String, _ handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        let param = ["path": remoteFile]
        let url = VaultURL.sharedInstance.deleteFileOrFolder()
        return VaultApi.requestWithBool(url: url, parameters: param, headers: Header(authHelper).headers())
    }

    func move(_ src: String, _ dest: String) -> HivePromise<Bool> {
        return move(src, dest, handler: HiveCallback())
    }

    func move(_ src: String, _ dest: String, handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.moveImp(src, dest, handler)
        }
    }

    private func moveImp(_ src: String, _ dest: String, _ handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        let url = VaultURL.sharedInstance.move()
        let param = ["src_path": src, "dst_path": dest]
        return VaultApi.requestWithBool(url: url, parameters: param, headers: Header(authHelper).headers())
    }

    func copy(_ src: String, _ dest: String) -> HivePromise<Bool> {
        return copy(src, dest, handler: HiveCallback())
    }

    func copy(_ src: String, _ dest: String, handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        return authHelper.checkValid().then { _ -> HivePromise<Bool> in
            return self.copyImp(src, dest, handler)
        }
    }

    private func copyImp(_ src: String, _ dest: String, _ handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        let url = VaultURL.sharedInstance.move()
        let param = ["src_path": src, "dst_path": dest]
        return VaultApi.requestWithBool(url: url, parameters: param, headers: Header(authHelper).headers())
    }

    func hash(_ path: String) -> HivePromise<String> {
        return hash(path, handler: HiveCallback())
    }

    func hash(_ path: String, handler: HiveCallback<String>) -> HivePromise<String> {
        return authHelper.checkValid().then { _ -> HivePromise<String> in
            return self.hashImp(path, handler)
        }
    }

    private func hashImp(_ path: String, _ handler: HiveCallback<String>) -> HivePromise<String> {
        return HivePromise<String> { resolver in
            let url = VaultURL.sharedInstance.hash(path)
            VaultApi.request(url: url, method: .get, headers: Header(authHelper).headers()).done { json in
                resolver.fulfill(json["SHA256"].stringValue)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    func list(_ path: String) -> HivePromise<Array<FileInfo>> {
        return list(path, handler: HiveCallback())
    }

    func list(_ path: String, handler: HiveCallback<Array<FileInfo>>) -> HivePromise<Array<FileInfo>> {
        return authHelper.checkValid().then { _ -> HivePromise<Array<FileInfo>> in
            return self.listImp(path, handler)
        }
    }

    private func listImp(_ path: String, _ handler: HiveCallback<Array<FileInfo>>) -> HivePromise<Array<FileInfo>> {
        return HivePromise<Array<FileInfo>> { resolver in
            let url = VaultURL.sharedInstance.list(path)
            VaultApi.request(url: url, method: .get, headers: Header(authHelper).headers()).done { json in
                let arraryInfo = json["file_info_list"].arrayValue
                var fileList = [FileInfo]()
                arraryInfo.forEach { j in
                    let info = FileInfo()
                    info.setName(j["name"].stringValue)
                    info.setSize(j["size"].intValue)
                    info.setLastModify(j["last_modify"].stringValue)
                    info.setType(j["type"].stringValue)
                    fileList.append(info)
                }
                resolver.fulfill(fileList)
            }.catch { error in
                resolver.reject(error)
            }
        }
    }

    func stat(_ path: String) -> HivePromise<Array<FileInfo>> {
        return stat(path, handler: HiveCallback())
    }

    func stat(_ path: String, handler: HiveCallback<Array<FileInfo>>) -> HivePromise<Array<FileInfo>> {
        return HivePromise<Array<FileInfo>>(error: "TODO" as! Error)
    }


}
