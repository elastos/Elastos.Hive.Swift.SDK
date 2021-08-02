/*
 * Copyright (c) 2020 Elastos Foundation
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

import UIKit
import RxSwift
import RxCocoa

class CallerViewController: UIViewController {
    
    let runScriptButton = UIButton()
    let textView: UITextView = UITextView()
    var sdkContext: SdkContext?
    var scriptCaller: ScriptCaller?
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.tabBarController?.tabBar.isTranslucent = false
        
        self.title = "Caller"
        
        self.runScriptButton.setTitle("RUN SCRIPT", for: UIControl.State.normal)
        self.runScriptButton.backgroundColor = UIColor(rgb: 0x333333)
        self.runScriptButton.layer.cornerRadius = 4
        self.runScriptButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        self.view.addSubview(self.runScriptButton)
        self.runScriptButton.snp.makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.view).offset(20)
            make.width.equalTo(self.view).multipliedBy(0.8)
            make.height.equalTo(44)
        }
        
        self.view.addSubview(self.textView)
        self.textView.layer.cornerRadius = 4
        self.textView.layer.borderColor = UIColor(rgb: 0x333333).cgColor
        self.textView.layer.borderWidth = 1
        self.textView.font = UIFont.systemFont(ofSize: 20)
        self.textView.snp.makeConstraints { make in
            make.top.equalTo(self.runScriptButton.snp.bottom).offset(20)
            make.left.equalTo(self.view).offset(20)
            make.right.bottom.equalTo(self.view).offset(-20)
        }
        
        do {
            self.sdkContext = try SdkContext()
            self.scriptCaller = try ScriptCaller(self.sdkContext!)
        } catch {
            print("\(error)")
        }
        
        self.runScriptButton.rx.tap.subscribe { event in
            
            self.scriptCaller!.runScript().done({ json in
                DispatchQueue.main.async {
                    self.textView.text = "success"
                }
            }).catch { error in
                DispatchQueue.main.async {
                    self.textView.text = "\(error)"
                }
            }
        }.disposed(by: self.disposeBag)
    }
    
}
