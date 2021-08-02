//
//  DashboardViewController.swift
//  HiveExamples
//
//  Created by 韩丛旸 on 2021/8/2.
//

import UIKit
import RxSwift
import SnapKit

class DashboardViewController: UIViewController {

    private var scriptCaller: ScriptCaller?
    let textView: UITextView = UITextView()
    let button = UIButton()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.tabBarController?.tabBar.isTranslucent = false
        
        self.button.setTitle("RUN SCRIPT", for: UIControl.State.normal)
        self.button.backgroundColor = UIColor(rgb: 0x333333)
        self.button.layer.cornerRadius = 4
        self.button.titleLabel?.font = UIFont.systemFont(ofSize: 20)


        self.view.addSubview(self.button)
        self.button.snp.makeConstraints { make in
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
            make.top.equalTo(self.button.snp.bottom).offset(20)
            make.left.equalTo(self.view).offset(20)
            make.right.bottom.equalTo(self.view).offset(-20)
        }

        
    }
    
    public func runScript() {
        self.scriptCaller?.runScript().done({ json in
            self.textView.text = "\(json)"
        }).catch({ error in
            self.textView.text = "\(error)"
        })
    }

}
