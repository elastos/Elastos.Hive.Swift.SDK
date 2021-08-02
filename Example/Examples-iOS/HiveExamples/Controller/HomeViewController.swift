//
//  DashboardViewController.swift
//  HiveExamples
//
//  Created by 韩丛旸 on 2021/8/2.
//

import UIKit
import RxSwift
import SnapKit

class HomeViewController: UIViewController {
    private var scriptOwner: ScriptOwner?
    let textView: UITextView = UITextView()
    let registerScriptButton = UIButton()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scriptOwner = try! ScriptOwner(try! SdkContext())
        
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.tabBarController?.tabBar.isTranslucent = false
        
        self.registerScriptButton.setTitle("REGISTER SCRIPT", for: UIControl.State.normal)
        self.registerScriptButton.backgroundColor = UIColor(rgb: 0x333333)
        self.registerScriptButton.layer.cornerRadius = 4
        self.registerScriptButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        self.registerScriptButton.rx.tap.subscribe { event in
            self.scriptOwner!.setScript().done({ result in
                DispatchQueue.main.async {
                    self.textView.text = "success"
                }
            }).catch({ error in
                DispatchQueue.main.async {
                    self.textView.text = "\(error)"
                }
            })
            
        }.disposed(by: self.disposeBag)

        self.view.addSubview(self.registerScriptButton)
        self.registerScriptButton.snp.makeConstraints { make in
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
            make.top.equalTo(self.registerScriptButton.snp.bottom).offset(20)
            make.left.equalTo(self.view).offset(20)
            make.right.bottom.equalTo(self.view).offset(-20)
        }
    }
}
