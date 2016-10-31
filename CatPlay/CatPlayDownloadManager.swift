//
//  CatPlayDownloadManager.swift
//  CatPlay
//
//  Created by li.min on 2016/10/25.
//  Copyright © 2016年 li.min. All rights reserved.
//

import Foundation

//断点下载
class CatPlayDownloadManager:NSObject,URLSessionDownloadDelegate{
    var resumeData:Data?
    var task:URLSessionDownloadTask!
    var session:URLSession!
    var urlRequest:URLRequest!
    var progress:((Float)->())?
    override init(){
        super.init()
    }
    
    func start(){
        if task == nil {
            print("开始下载")
            initTask()
            task = session.downloadTask(with: urlRequest)
            task.resume()
        }
    }
    
    func suspend(){
        guard task == nil else{
            return task.cancel { (data) in
                self.resumeData = data
                print("暂停下载")
            }
        }
    }
    
    func resume(){
         print("继续下载")
        if let data = resumeData {
            task = session.downloadTask(withResumeData: data)
            task.resume()
        }
    }
    
    func cancle(){
        print("取消下载")
        guard task == nil else {
            task.cancel()
            return task = nil
        }
    }
    
    func initTask(){
        let configuration = URLSessionConfiguration.default
        session = URLSession.init(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        let urlString = "http://www.1ting.com/api/audio?/i/1031/7/14.mp3"
        let encodingString = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let url = URL.init(string: encodingString!)
        urlRequest = URLRequest.init(url: url!, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 20)
        
    }
    
    //暂停，取消都会调用的方法，获取resumeData
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let myerror = error {
            print("didcomplete"+myerror.localizedDescription)
        }
    }
    
    //完成下载，移动下载文件
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("下载结束")
        let locationPath = location.path
        print(locationPath)
        let documents = NSHomeDirectory() + "/Documents/14.mp3"
        print(documents)
        let defaultFile = FileManager.default
        do {
            try defaultFile.moveItem(atPath: locationPath, toPath: documents)
            try defaultFile.removeItem(atPath: documents)
        }catch let error {
            print("didFinish"+error.localizedDescription)
        }
        
        }
    
    //开始断点下载调用
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
    }
    
    //正在下载
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let finishedPRogress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        progress?(finishedPRogress)
    }
    
    
}
