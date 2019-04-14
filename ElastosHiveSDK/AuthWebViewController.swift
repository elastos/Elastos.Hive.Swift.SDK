

import UIKit
import WebKit

class AuthWebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    var webView: WKWebView?
    var initialRequest: URLRequest?
    var endURL: NSURL?
    var timer: Timer?
    var isComplete: Bool?
    typealias ResponseHandle = (_ responsrUri: URL?, _ error: Error?) -> Void
    public var responseHandle: ResponseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView = WKWebView()
        self.webView?.uiDelegate = self
        self.webView?.navigationDelegate = self
        self.view.addSubview(self.webView!)
        self.webView?.frame = self.view.frame
        
        let cancel = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action:#selector(Progress.cancel))
        self.navigationController?.topViewController?.navigationItem.leftBarButtonItem = cancel
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.webView?.stopLoading()
        self.webView?.uiDelegate = nil
        self.webView?.navigationDelegate = nil
        super.viewWillAppear(animated)
    }
    
    public func loadRequest(_ clientId: String, _ redirectUri: String, _ responseType: String, _ scope: String){
        let authURLRequest: URLRequest = getOneDriveAuthonURL(clientId, redirectUri, responseType, scope)
        self.initialRequest = authURLRequest
        self.webView?.load(self.initialRequest!)
    }
    private func getOneDriveAuthonURL(_ clientId: String, _ redirectUri: String, _ responseType: String, _ scope: String)-> URLRequest {
        
        let params = [
            "client_id" : clientId,
            "scope" : scope,
            "redirect_uri" : redirectUri,
            "response_type" : responseType
        ]
        let authRootURL: String = AUTH_URL
        let paramString = params.queryString
        var urlComponents: URLComponents = URLComponents(url: URL(string: authRootURL)!, resolvingAgainstBaseURL: false)!
        urlComponents.query = paramString
        var request: URLRequest = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        return request
    }
    
    func cancel() {
        self .dismiss(animated: true, completion: nil)
    }
    
    //MARK:-WKNavigationDelegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: Selector(("failWithTimeout")), userInfo: nil, repeats: false)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        timer?.invalidate()
        self.timer = nil
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if let handle = responseHandle {
            handle(nil, error)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(WKNavigationActionPolicy.allow)
        if (navigationAction.request.url?.absoluteString.hasPrefix("https://login.live.com/oauth20_desktop.srf"))! {
            if let handle = responseHandle {
                handle(navigationAction.request.url, nil)
            }
        }
    }
    
    func failWithTimeout() {
        
        let timeOutError: NSError = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
        if let handle = responseHandle {
            handle(nil, timeOutError)
        }
        //        self.webView(self.webView, didFailLoadWithError: timeOutError)
    }
}

extension Dictionary {
    var queryString: String {
        var output: String = ""
        for (key,value) in self {
            output +=  "\(key)=\(value)&"
        }
        output = String(output.dropLast())
        return output
    }
}

extension URL {
    var queryDictionary: [String: String]? {
        guard let query = self.query else { return nil}
        
        var queryStrings = [String: String]()
        for pair in query.components(separatedBy: "&") {
            let key = pair.components(separatedBy: "=")[0]
            let value = pair
                .components(separatedBy:"=")[1]
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? ""
            queryStrings[key] = value
        }
        return queryStrings
    }
}
