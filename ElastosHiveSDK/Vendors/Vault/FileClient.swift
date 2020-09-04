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

class FileClient: FilesProtocol {
    private var authHelper: VaultAuthHelper

    public init(_ authHelper: VaultAuthHelper) {
        self.authHelper = authHelper
    }

    func upload(_ path: String) -> HivePromise<FileHandle> {
        return upload(path, handler: HiveCallback())
    }

    func upload(_ path: String, handler: HiveCallback<FileHandle>) -> HivePromise<FileHandle> {
        return HivePromise<FileHandle>(error: "TODO" as! Error)
    }

//    private func uploadImp(_ path: String, callback: HiveCallback<FileHandle>) -> HivePromise<FileHandle> {
//
//
//    }
    /*
     private CompletableFuture<Writer> uploadImp(String path, Callback<Writer> callback) {

         return CompletableFuture.supplyAsync(() -> {
             try {

                 URL reslUrl = new URL(path);
                 HttpURLConnection conn = (HttpURLConnection) reslUrl.openConnection();
                 conn.setDoOutput(true);
                 conn.setDoInput(true);
                 conn.setUseCaches(false);
                 conn.setRequestMethod("POST");
                 conn.setRequestProperty("Transfer-Encoding", "chunked");
                 conn.setRequestProperty("Connection", "Keep-Alive");
                 conn.setRequestProperty("Charsert", "UTF-8");
                 conn.setConnectTimeout(5000);
                 conn.setReadTimeout(5000);
                 conn.setChunkedStreamingMode(20 * 1024); //指定流的大小，当内容达到这个值的时候就把流输出

                 OutputStream outputStream = conn.getOutputStream();
                 OutputStreamWriter outputStreamWriter = new OutputStreamWriter(outputStream);

                 return outputStreamWriter;

             } catch (Exception e) {
                 HiveException exception = new HiveException(e.getLocalizedMessage());
                 callback.onError(exception);
                 throw new CompletionException(exception);
             }
         });
     }
     */
    func download(_ path: String) -> HivePromise<FileHandle> {
        return download(path, handler: HiveCallback())
    }

    func download(_ path: String, handler: HiveCallback<FileHandle>) -> HivePromise<FileHandle> {
        return HivePromise<FileHandle>(error: "TODO" as! Error)
    }

    func delete(_ path: String) -> HivePromise<Bool> {
        return delete(path, handler: HiveCallback())
    }

    func delete(_ path: String, handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        return HivePromise<Bool>(error: "TODO" as! Error)
    }

    func move(_ src: String, _ dest: String) -> HivePromise<Bool> {
        return move(src, dest, handler: HiveCallback())
    }

    func move(_ src: String, _ dest: String, handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        return HivePromise<Bool>(error: "TODO" as! Error)
    }

    func copy(_ src: String, _ dest: String) -> HivePromise<Bool> {
        return copy(src, dest, handler: HiveCallback())
    }

    func copy(_ src: String, _ dest: String, handler: HiveCallback<Bool>) -> HivePromise<Bool> {
        return HivePromise<Bool>(error: "TODO" as! Error)
    }

    func hash(_ path: String) -> HivePromise<String> {
        return hash(path, handler: HiveCallback())
    }

    func hash(_ path: String, handler: HiveCallback<String>) -> HivePromise<String> {
        return HivePromise<String>(error: "TODO" as! Error)
    }

    func list(_ path: String) -> HivePromise<Array<FileInfo>> {
        return list(path, handler: HiveCallback())
    }

    func list(_ path: String, handler: HiveCallback<Array<FileInfo>>) -> HivePromise<Array<FileInfo>> {
        return HivePromise<Array<FileInfo>>(error: "TODO" as! Error)
    }

    func stat(_ path: String) -> HivePromise<Array<FileInfo>> {
        return stat(path, handler: HiveCallback())
    }

    func stat(_ path: String, handler: HiveCallback<Array<FileInfo>>) -> HivePromise<Array<FileInfo>> {
        return HivePromise<Array<FileInfo>>(error: "TODO" as! Error)
    }


}
