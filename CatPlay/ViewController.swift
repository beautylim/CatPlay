//
//  ViewController.swift
//  CatPlay
//
//  Created by li.min on 2016/10/20.
//  Copyright © 2016年 li.min. All rights reserved.
//

import UIKit
class ViewController: UIViewController {

    var downLoadManager:CatPlayDownloadManager = CatPlayDownloadManager()
    
    
    @IBOutlet weak var progressLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downLoadManager.progress = {progress in
            self.progressLabel.text = "已经下载了 \(progress)"
        }
    
    }
    
    @IBAction func start(_ sender: AnyObject) {
        downLoadManager.start()
    }

    
    @IBAction func suspend(_ sender: AnyObject) {
        downLoadManager.suspend()
    }
    
    
    @IBAction func resume(_ sender: AnyObject) {
        downLoadManager.resume()
    }
    
    @IBAction func cancle(_ sender: AnyObject) {
        downLoadManager.cancle()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func setHttpAuth()->String{
        let userAccount = "账户"//需要自己改
        let password = "密码"//需要自己改
        let str = NSString.init(string: "\(userAccount):\(password)")
        let data = str.data(using: String.Encoding.utf8.rawValue)
        let base64 = data?.base64EncodedString(options: .lineLength64Characters)
        let authStr = "Basic \(base64!)"
        return authStr
    }
    
    fileprivate func getAuthDic()->[String:String]{
        return ["Authorization":setHttpAuth()]
    }

}

