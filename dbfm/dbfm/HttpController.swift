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
        Alamofire.manager.request(Method.GET, url).responseJSON(options: NSJSONReadingOptions.MutableContainers, completionHandler: {
            (_, _, data, error) in
            if data != nil {
                self.delegate?.onReceiveResults(data!)
            }
        })
    }
}

// 定义http协议
protocol HttpProtocol {
    func onReceiveResults(results: AnyObject)
}
