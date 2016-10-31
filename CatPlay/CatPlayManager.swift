//
//  CatPlayManager.swift
//  CatPlay
//
//  Created by li.min on 2016/10/20.
//  Copyright © 2016年 li.min. All rights reserved.
//

import Foundation
let uploadImageHostURL:String = "http://www.freeimagehosting.net/upload.php"//上传图片
let uploadDataHostURL:String = "http://jsonplaceholder.typicode.com/posts"//上传文件
public enum HTTPMethod:String{
    case GET  = "GET"
    case POST = "POST"
    case PUT  = "PUT"
}

enum HTTPErrorCode:Int{
    case unknowReason = 0000
    case nilResponseData = 0001
    case failureSerializer = 0002
}

class CatPlayManager:NSObject, URLSessionTaskDelegate{
    let hostURL:String = "自己某个服务器"
    static let shareInstance = CatPlayManager()
    var uploadDataProgress:((Double)->())?
    fileprivate override init(){
        
    }
    
    
    func request(url urlString:String,method:HTTPMethod,parameter:[String:Any]?=nil,header:[String:String]?=nil,success:((Any)->())?=nil,failure:((HTTPError)->())?=nil){
        //1.生成configuration
        let defaultConfiguration = URLSessionConfiguration.default
        
        //2.生成session
        let session = URLSession.init(configuration: defaultConfiguration)
        var httpString = hostURL + "/" + urlString
        if method == .GET,let parameterDic = parameter {
            httpString += "?"
            for (key,value) in parameterDic {
                httpString += "\(key)=\(value)&"
            }
            httpString = httpString.substring(to: httpString.endIndex)
        }
        
        //3.生成url
        let encodingURL = httpString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let httpURL = URL.init(string: encodingURL!)
        
        //4.生成URLRequest
        var httpRequest = URLRequest.init(url: httpURL!)
        httpRequest.httpMethod = method.rawValue
        if let httpHeader = header{
            httpRequest.allHTTPHeaderFields = httpHeader
        }
        httpRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        httpRequest.httpMethod = method.rawValue
        if method == .POST,let parameterDic = parameter {
            var httpBodyString = ""
            for (key,value) in parameterDic {
                httpBodyString += "\(key)=\(value)&"
            }
            httpBodyString = httpBodyString.substring(to: httpBodyString.endIndex)
            httpRequest.httpBody = httpBodyString.data(using: String.Encoding.utf8)
        }
        
        //5.生成URLSessiontask
        let sessionTask = session.dataTask(with: httpRequest) {(responseData, urlResponse, error) in
            let result:CatPlayResponseResult = self.responseJSONSerializer(responseData: responseData, response: urlResponse, error: error)
            switch result{
            case .success(let response):
                success!(response)
            case .failure(let catPlayError):
                failure!(catPlayError)
            }
        }
        
        sessionTask.resume()
    }
    
    func upload(method:HTTPMethod,url:String,contentType:String,acceptType:String,fromData:()->(Data),progress:((Double)->())?=nil,success:((Any)->())?=nil,failure:((HTTPError)->())?=nil){
        
        self.uploadDataProgress = progress
        //1.生成configuration
        let defaultConfiguration = URLSessionConfiguration.default
        
        //2.生成session
        let session = URLSession.init(configuration: defaultConfiguration, delegate: self, delegateQueue: nil)
        
        //3.生成url
        let encodingURL = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let httpURL = URL.init(string: encodingURL!)
        
        //4.生成URLRequest
        var httpRequest = URLRequest.init(url: httpURL!)
        httpRequest.httpMethod = method.rawValue
        
        //这些两个一定要设置
        httpRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        httpRequest.setValue(acceptType, forHTTPHeaderField: "Accept")
        httpRequest.cachePolicy = .reloadIgnoringCacheData
        httpRequest.timeoutInterval = 20
        
        let uploadData = fromData()
        let uploadTask = session.uploadTask(with: httpRequest, from: uploadData) { (responseData, urlResponse, error) in
            let result:CatPlayResponseResult = self.responseJSONSerializer(responseData: responseData, response: urlResponse, error: error)
            switch result{
            case .success(let response):
                success!(response)
            case .failure(let catPlayError):
                failure!(catPlayError)
            }
            
        }
        uploadTask.resume()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        if let progress = self.uploadDataProgress{
            let nowPercent = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
            progress(nowPercent)
        }
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        //https验证
    }
    
    
    //序列化
    func responseJSONSerializer(responseData:Data?,response:URLResponse?,error:Error?)->CatPlayResponseResult{
        print(response!)
        guard error == nil else { return CatPlayResponseResult.failure(HTTPError.init(reason: "有不明错误", statusCode:HTTPErrorCode.unknowReason))}
        guard let data = responseData , data.count > 0 else {
            return CatPlayResponseResult.failure(HTTPError.init(reason: "什么都没有返回", statusCode: HTTPErrorCode.nilResponseData))
        }
        do{
            let json = try JSONSerialization.jsonObject(with: data, options:.allowFragments)
            return CatPlayResponseResult.success(json)
        }catch{
            return CatPlayResponseResult.failure(HTTPError.init(reason: "解析失败", statusCode:HTTPErrorCode.failureSerializer))
        }
    }
    
    func responseStringSerializer(responseData:Data?,response:URLResponse?,error:Error?)->CatPlayResponseResult{
        print(response!)
        guard error == nil else { return CatPlayResponseResult.failure(HTTPError.init(reason: "有不明错误", statusCode:HTTPErrorCode.unknowReason))}
        guard let data = responseData , data.count > 0 else {
            return CatPlayResponseResult.failure(HTTPError.init(reason: "什么都没有返回", statusCode: HTTPErrorCode.nilResponseData))
        }
        let resultString =  String.init(data: responseData!, encoding: String.Encoding.utf8)
        return CatPlayResponseResult.success(resultString)
    }
    
}

enum CatPlayResponseResult{
    case success(Any)
    case failure(HTTPError)
}

class HTTPError {
    var reason:String = ""
    var statusCode = 0
    init(reason:String,statusCode:HTTPErrorCode) {
        self.reason = reason
        self.statusCode = statusCode.rawValue
    }
}

