

import UIKit
import WebKit

public class AuthWebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    var webView: WKWebView?
    var initialRequest: URLRequest?
    var endURL: NSURL?
    var timer: Timer?
    var isComplete: Bool?
    typealias ResponseHandle = (_ responsrUri: URL?, _ error: Error?) -> Void
    var responseHandle: ResponseHandle?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.webView = WKWebView()
        self.webView?.uiDelegate = self
        self.webView?.navigationDelegate = self
        self.view.addSubview(self.webView!)
        self.webView?.frame = self.view.frame
        
        let cancel = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action:#selector(Progress.cancel))
        self.navigationController?.topViewController?.navigationItem.leftBarButtonItem = cancel
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        self.webView?.stopLoading()
        self.webView?.uiDelegate = nil
        self.webView?.navigationDelegate = nil
        super.viewWillAppear(animated)
    }
    
    public func loadRequest(_ requestURL: String){
        let authURLRequest: URLRequest = getOneDriveAuthonURL(requestURL)
        self.initialRequest = authURLRequest
        self.webView?.load(self.initialRequest!)
    }
    private func getOneDriveAuthonURL(_ requestURL: String)-> URLRequest {
        
        let url = URL(string: requestURL)
        let urlComponents: URLComponents = URLComponents(url: url!, resolvingAgainstBaseURL: false)!
        var request: URLRequest = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        return request
    }
    
    func cancel() {
        self .dismiss(animated: true, completion: nil)
    }
    
    //MARK:-WKNavigationDelegate
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(failWithTimeout), userInfo: nil, repeats: false)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        timer?.invalidate()
        self.timer = nil
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if let handle = responseHandle {
            handle(nil, error)
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(WKNavigationActionPolicy.allow)
        if (navigationAction.request.url?.absoluteString.hasPrefix(REDIRECT_URI))! {
            if let handle = responseHandle {
                handle(navigationAction.request.url, nil)
            }
        }
    }
    
    @objc func failWithTimeout() {
        
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

