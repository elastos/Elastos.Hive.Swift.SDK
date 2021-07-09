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

public class CredentialCode {
    private var _targetServiceDid: String?
    private var _jwtCode: String?
    private var _remoteResolver: CodeFetcherProtocol?
    private var _storage: DataStorageProtocol?
    
    public init(_ endpoint: ServiceEndpoint, _ context: BackupContext) {
        _targetServiceDid = context.getParameter("targetServiceDid")
        let remoteResolver: CodeFetcherProtocol = Remo
    }
}

public class CredentialCode {
    private String targetServiceDid;
    private String jwtCode;
    private CodeFetcher remoteResolver;
    private DataStorage storage;

    public CredentialCode(ServiceEndpoint endpoint, BackupContext context) {
        targetServiceDid = context.getParameter("targetServiceDid");
        CodeFetcher remoteResolver = new RemoteResolver(
                endpoint, context, targetServiceDid,
                context.getParameter("targetAddress"));
        this.remoteResolver = new LocalResolver(endpoint, remoteResolver);
        storage = endpoint.getStorage();
    }

    public String getToken() throws HiveException {
        if (jwtCode != null)
            return jwtCode;

        jwtCode = restoreToken();
        if (jwtCode == null) {
            try {
                jwtCode = remoteResolver.fetch();
            } catch (NodeRPCException e) {
                throw new HiveException(e.getMessage());
            }

            if (jwtCode != null) {
                saveToken(jwtCode);
            }
        }
        return jwtCode;
    }

    private String restoreToken() {
        return storage.loadBackupCredential(targetServiceDid);
    }

    private void saveToken(String jwtCode) {
        storage.storeBackupCredential(targetServiceDid, jwtCode);
    }
}
