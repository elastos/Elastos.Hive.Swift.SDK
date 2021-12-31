//
//  DashboardViewController.swift
//  HiveExamples
//
//  Created by 韩丛旸 on 2021/8/2.
//

import UIKit
import RxSwift
import SnapKit
import RxCocoa
import SVProgressHUD
import ObjectMapper
import SwiftyJSON
import PromiseKit
import ElastosHiveSDK

class HomeViewController: UIViewController {
    private var scriptOwner: ScriptOwner!
    let textView: UITextView = UITextView()
    let registerScriptButton = UIButton()
    let vaultScriptButton = UIButton()
    let uploadFileButton = UIButton()
    let downloadFileButton = UIButton()
    let showImage = UIImageView()
    let disposeBag = DisposeBag()
    var loadingFlag: Bool = false
    var imgDate: Data!
    let scriptName = "upload_file"
    let fileName = "test_ios_image"
    let DOWNLOAD_FILE_NAME = "download_file"
    var param: [String: String]!
    var targetAppDid = ""
    var targetDid = ""
    var targetUrl: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scriptOwner = try! ScriptOwner(SdkContext.instance)
        
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.tabBarController?.tabBar.isTranslucent = false
        
        self.registerScriptButton.setTitle("REGISTER SCRIPT", for: UIControl.State.normal)
        self.registerScriptButton.backgroundColor = UIColor(rgb: 0x333333)
        self.registerScriptButton.layer.cornerRadius = 4
        self.registerScriptButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        self.registerScriptButton.rx.tap.subscribe { event in
            if self.loadingFlag == true {
                return
            }
            self.loadingFlag = true
            SVProgressHUD.show()
            self.scriptOwner.setScript().done({ result in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.loadingFlag = false
                    self.textView.text = "success"
                }
            }).catch({ error in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.loadingFlag = false
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
        
        // vaultScriptButton
        self.vaultScriptButton.setTitle("VAULT SUBSCRIBE", for: UIControl.State.normal)
        self.vaultScriptButton.backgroundColor = UIColor(rgb: 0x333333)
        self.vaultScriptButton.layer.cornerRadius = 4
        self.vaultScriptButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        self.vaultScriptButton.rx.tap.subscribe { event in
            if self.loadingFlag == true {
                return
            }
            self.loadingFlag = true
            SVProgressHUD.show()
            self.scriptOwner.backupSubscription.subscribe().done{ backupInfo in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.loadingFlag = false
                    let serviceDid = "\(backupInfo.serviceDid ?? "")"
                    let storageQuota = "\(backupInfo.storageQuota ?? 0)"
                    let storageUsed = "\(backupInfo.storageUsed ?? 0)"
                    let created = "\(backupInfo.created ?? 0)"
                    let updated = "\(backupInfo.updated ?? 0)"
                    let pricePlan = "\(backupInfo.pricePlan ?? "")"
                    let text = "success: \nserviceDid: \(serviceDid) \nstorageQuota: \(storageQuota) \nstorageUsed: \(storageUsed) \ncreated: \(created) \nupdated: \(updated) \npricePlan: \(pricePlan)"
                    self.textView.text = text
                }
            }.catch({ error in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.loadingFlag = false
                    self.textView.text = "\(error)"
                }
            })
                    
        }.disposed(by: self.disposeBag)
        
        self.view.addSubview(self.vaultScriptButton)
        self.vaultScriptButton.snp.makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.registerScriptButton.snp.bottom).offset(20)
            make.width.equalTo(self.view).multipliedBy(0.8)
            make.height.equalTo(44)
        }
        
        // uploadFileButton
        self.uploadFileButton.setTitle("UPLOAD FILE", for: UIControl.State.normal)
        self.uploadFileButton.backgroundColor = UIColor(rgb: 0x333333)
        self.uploadFileButton.layer.cornerRadius = 4
        self.uploadFileButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        self.uploadFileButton.addTarget(self, action: #selector(goPhoto), for: .touchUpInside)
        
        self.view.addSubview(self.uploadFileButton)
        self.uploadFileButton.snp.makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.vaultScriptButton.snp.bottom).offset(20)
            make.width.equalTo(self.view).multipliedBy(0.8)
            make.height.equalTo(44)
        }
        
        // downloadFileButton
        self.downloadFileButton.setTitle("DOWNLOAD FILE", for: UIControl.State.normal)
        self.downloadFileButton.backgroundColor = UIColor(rgb: 0x333333)
        self.downloadFileButton.layer.cornerRadius = 4
        self.downloadFileButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        
        self.view.addSubview(self.downloadFileButton)
        self.downloadFileButton.snp.makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.uploadFileButton.snp.bottom).offset(20)
            make.width.equalTo(self.view).multipliedBy(0.8)
            make.height.equalTo(44)
        }
        self.downloadFileButton.rx.tap.subscribe { event in
            if self.loadingFlag == true {
                return
            }
            self.loadingFlag = true
            SVProgressHUD.show()
            self.scriptOwner.scriptingService.registerScript(self.scriptName, FileDownloadExecutable(self.scriptName).setOutput(true), false, false).then { _ -> Promise<JSON> in
                return self.scriptOwner.scriptRunner.callScript(self.scriptName, Executable.createRunFileParams(self.fileName), self.targetDid, self.targetAppDid, JSON.self)
            }.then { json -> Promise<FileReader> in
                let txid = json[self.scriptName]["transaction_id"].stringValue
                return self.scriptOwner.scriptRunner.downloadFile(txid)
            }.then{ reader -> Promise<Bool> in
                self.targetUrl = self.createFilePathForDownload("test_ios_download_script")
                return reader.read(self.targetUrl)
            }.done{ success in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.loadingFlag = false
                    let data = try! Data(contentsOf: self.targetUrl)
                    self.showImage.image = UIImage(data: data)
                    let text = success == true ? "download image: success" : "download image: false"
                    self.textView.text = text
                }
            }
            .catch { error in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.loadingFlag = false
                    let errMsg = "\n注意：\n点击'DOWNLOAD FILE' 之前，请先点击'UPLOAD FILE'"
                    self.textView.text = "\(error)\(errMsg)"
                }
            }
            
        }.disposed(by: self.disposeBag)
        
        //  showImage
        self.showImage.backgroundColor = UIColor.white
        self.view.addSubview(self.showImage)
        self.showImage.snp.makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.downloadFileButton.snp.bottom).offset(20)
            make.width.equalTo(self.view).multipliedBy(0.8)
            make.height.equalTo(120)
        }
        
        self.view.addSubview(self.textView)
        self.textView.layer.cornerRadius = 4
        self.textView.layer.borderColor = UIColor(rgb: 0x333333).cgColor
        self.textView.layer.borderWidth = 1
        self.textView.font = UIFont.systemFont(ofSize: 20)
        self.textView.isEditable = false
        self.textView.snp.makeConstraints { make in
            make.top.equalTo(self.showImage.snp.bottom).offset(20)
            make.left.equalTo(self.view).offset(20)
            make.right.bottom.equalTo(self.view).offset(-20)
        }
    }
    
    func createFilePathForDownload(_ downloadPath: String) -> URL {
        let dir = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last
        let fileurl = dir?.appendingPathComponent(downloadPath)
        if !FileManager.default.fileExists(atPath: fileurl!.path) {
            FileManager.default.createFile(atPath: fileurl!.path, contents: nil, attributes: nil)
        } else {
            try? FileManager.default.removeItem(atPath: fileurl!.path)
            FileManager.default.createFile(atPath: fileurl!.path, contents: nil, attributes: nil)
        }
        return fileurl!
    }
    
    @objc func goPhoto() {
        let photoPicker = UIImagePickerController()
        photoPicker.delegate = self
        photoPicker.allowsEditing = true
        photoPicker.sourceType = .photoLibrary
        self.present(photoPicker, animated: true, completion: nil)
    }
    
    func uploadImage() {
        if self.loadingFlag == true {
            return
        }
        self.loadingFlag = true
        SVProgressHUD.show()
        
        param = Executable.createRunFileParams(fileName)
        targetAppDid = self.scriptOwner.sdkContext.appId
        targetDid = self.scriptOwner.sdkContext.userDid
        self.scriptOwner.scriptingService.registerScript(scriptName, FileUploadExecutable(scriptName).setOutput(true), false, false)
            .then { _ -> Promise<JSON> in
                return self.scriptOwner.scriptingService.callScript(self.scriptName, self.param, self.targetDid, self.targetAppDid, JSON.self)
            }.then { json -> Promise<FileWriter> in
                print(json)
                let txid = json[self.scriptName]["transaction_id"].stringValue
                return self.scriptOwner.scriptRunner.uploadFile(txid)
            }.then { writer in
                return try writer.write(data: self.imgDate)
            }
            .done{ success in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.loadingFlag = false
                    let text = success == true ? "upload image: success" : "upload image: false"
                    self.textView.text = text
                }
            }
            .catch { error in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.loadingFlag = false
                    self.textView.text = "\(error)"
                }
            }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
@available(iOS 11.0, *)
extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image : UIImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imgDate = NSData(data: image.jpegData(compressionQuality: 1)!) as Data
        //        showImage.image = image
        uploadImage()
        self.dismiss(animated: true, completion: nil)
    }
}
