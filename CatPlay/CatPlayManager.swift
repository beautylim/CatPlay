//
//  CatPlayManager.swift
//  CatPlay
//
//  Created by li.min on 2016/10/20.
//  Copyright © 2016年 li.min. All rights reserved.
//

import Foundation
public enum HTTPMethod:String{
    case GET  = "GET"
    case POST = "POST"
}

enum HTTPErrorCode:Int{
    case unknowReason = 0000
    case nilResponseData = 0001
}

class CatPlayManager{
    var hostURL:String {
        get {
            return "http://Redmine.adways.cn/redmine"
        }
        set{
            self.hostURL = newValue
        }
    }
    static let shareInstance = CatPlayManager()
    fileprivate init(){
        
    }
    
    func request(url urlString:String,method:HTTPMethod,parameter:[String:Any]?=nil,header:[String:String]?=nil,Success:@escaping (Data,URLResponse)->(),failure:@escaping (HTTPError)->()){
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
        let sessionTask = session.dataTask(with: httpRequest) { (responseData, urlResponse, error) in
            guard error == nil else { return failure(HTTPError.init(reason: "有不明错误", statusCode:HTTPErrorCode.unknowReason))}
            guard let data = responseData , data.count > 0 else {
               return failure(HTTPError.init(reason: "什么都没有返回", statusCode: HTTPErrorCode.nilResponseData))
            }
            Success(responseData!,urlResponse!)
            
            
        }
        
        sessionTask.resume()
    }
}

class HTTPError {
    var reason:String = ""
    var statusCode = 0
    init(reason:String,statusCode:HTTPErrorCode) {
        self.reason = reason
        self.statusCode = statusCode.rawValue
    }
}

