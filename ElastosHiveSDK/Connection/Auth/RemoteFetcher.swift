///*
//* Copyright (c) 2020 Elastos Foundation
//*
//* Permission is hereby granted, free of charge, to any person obtaining a copy
//* of this software and associated documentation files (the "Software"), to deal
//* in the Software without restriction, including without limitation the rights
//* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//* copies of the Software, and to permit persons to whom the Software is
//* furnished to do so, subject to the following conditions:
//*
//* The above copyright notice and this permission notice shall be included in all
//* copies or substantial portions of the Software.
//*
//* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//* SOFTWARE.
//*/
//
//import Foundation
//
//public class RemoteFetcher: CodeFetcherProtocol {
//    private var _contextProvider: AppContextProvider?
//    private var _controller: AuthController?
//    
//    public init(_ serviceEndpoint: ServiceEndpoint) {
//
//    }
//    
//    public func fetch() throws -> String? {
//        return nil
//    }
//    
//    public func invalidate() {
//        
//    }
//}
//
///*
//class RemoteFetcher implements CodeFetcher {
//    private AppContextProvider contextProvider;
//    private AuthController controller;
//
//    public RemoteFetcher(ServiceEndpoint serviceEndpoint) {
//        this.contextProvider = serviceEndpoint.getAppContext().getAppContextProvider();
//        this.controller = new AuthController(serviceEndpoint, contextProvider.getAppInstanceDocument());
//    }
//
//    @Override
//    public String fetch() throws NodeRPCException {
//        try {
//            String challenge = controller.signIn(contextProvider.getAppInstanceDocument());
//
//            String challengeResponse = contextProvider.getAuthorization(challenge).get();
//            return controller.auth(challengeResponse);
//        } catch (Exception e) {
//            // TODO: log here.
//            e.printStackTrace();
//            throw new NodeRPCException(401,-1, "Failed to get token by auth requests.");
//        }
//    }
//
//    @Override
//    public void invalidate() {}
//}
//*/
//
////class RemoteFetcher implements CodeFetcher {
////    private AppContextProvider contextProvider;
////    private AuthController controller;
////
////    public RemoteFetcher(ServiceEndpoint serviceEndpoint) {
////        this.contextProvider = serviceEndpoint.getAppContext().getAppContextProvider();
////        this.controller = new AuthController(serviceEndpoint, contextProvider.getAppInstanceDocument());
////    }
////
////    @Override
////    public String fetch() throws NodeRPCException {
////        try {
////            String challenge = controller.signIn(contextProvider.getAppInstanceDocument());
////
////            String challengeResponse = contextProvider.getAuthorization(challenge).get();
////            return controller.auth(challengeResponse);
////        } catch (Exception e) {
////            // TODO: log here.
////            e.printStackTrace();
////            throw new NodeRPCException(401,-1, "Failed to get token by auth requests.");
////        }
////    }
////
////    @Override
////    public void invalidate() {}
////}
