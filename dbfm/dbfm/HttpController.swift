//
//  HttpController.swift
//  dbfm
//
//  Created by tutujiaw on 15/5/23.
//  Copyright (c) 2015年 tujiaw. All rights reserved.
//

import UIKit

class HttpController : NSObject {
    var delegate: HttpProtocol?
    
    func onSearch(url: String) {
        Alamofire.manager.request(Method.GET, url).responseJSON(options: NSJSONReadingOptions.MutableContainers, completionHandler: {(_, _, data, error) in self.delegate?.onReceiveResults(data!)})
    }
    
    func searchLyric(url: String) {
        Alamofire.manager.request(.GET, url, parameters: nil).responseString(encoding:NSUTF8StringEncoding, completionHandler: {
            (request, response, data, error) in
            println(request)
            println(response)
            println(error)
        })
    }
}
// 定义http协议
protocol HttpProtocol {
    func onReceiveResults(results: AnyObject)
}
