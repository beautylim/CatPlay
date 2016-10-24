//
//  ViewController.swift
//  CatPlay
//
//  Created by li.min on 2016/10/20.
//  Copyright © 2016年 li.min. All rights reserved.
//

import UIKit
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        CatPlayManager.shareInstance.request(url: "issues.json", method: .GET, parameter: ["assign_to":"me"], header: getAuthDic(), success: { (response) in
            
                print("success connect!")
            }) { (error) in
                print("\(error.reason)  and  \(error.statusCode)")
        }
        
        //上传图片
        
        CatPlayManager.shareInstance.upload(method: .POST, url:uploadImageHostURL, contentType: "image/jpeg", acceptType: "application/json", fromData: { () -> (Data) in
            let uploadImage = UIImage.init(named: "image_01")
            return UIImageJPEGRepresentation(uploadImage!, 1.0)!
            },progress: {percent in
                print("已经上传了\(percent)")
            }, success: { (response) in
                print("success upload image")
            }) { (error) in
                print("\(error.reason)  and  \(error.statusCode)")
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func setHttpAuth()->String{
        let userAccount = "yang.hao"//需要自己改
        let password = "11111111"//需要自己改
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

