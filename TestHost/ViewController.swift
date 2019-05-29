//
//  ViewController.swift
//  TestHost
//
//  Created by 李爱红 on 2019/5/28.
//  Copyright © 2019 org.elastos. All rights reserved.
//

import UIKit

let BASE_REQURL: String = "https://login.microsoftonline.com/common/oauth2/v2.0"
let AUTH_URL: String = BASE_REQURL + "/authorize"
let TOKEN_URL: String = BASE_REQURL + "/token"
let RESTAPI_URL: String = "https://graph.microsoft.com/v1.0/me/drive"
let REDIRECT_URI: String = "http://localhost:44316"
let ROOT_DIR: String = "/root"

// mark - string constant
let HEADER_AUTHORIZATION: String = "Authorization"
let ACCESS_TOKEN = "access_token"
let REFRESH_TOKEN = "refresh_token"
let EXPIRES_IN = "expires_in"
let SCOPE = "scope"
let AUTHORIZATION_CODE = "authorization_code"

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let scops = ["Files.ReadWrite","offline_access"]
        let scopStr = scops.joined(separator: " ")
        let authViewController: AuthWebViewController = AuthWebViewController()
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        rootViewController!.present(authViewController, animated: true, completion: nil)
        authViewController.loadRequest("31c2dacc-80e0-47e1-afac-faac093a739c", REDIRECT_URI, "code", scopStr)
    }

}

