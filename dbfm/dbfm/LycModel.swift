//
//  LycModel.swift
//  dbfm
//
//  Created by tutujiaw on 15/5/30.
//  Copyright (c) 2015年 tujiaw. All rights reserved.
//

import Foundation

extension String {
    func substr(pos: Int, len: Int = 0) -> String {
        if count(self) <= pos {
            return ""
        }
        let start = advance(self.startIndex, pos)
        let end = (0 == len ? self.endIndex : advance(self.startIndex, pos + len))
        return self.substringWithRange(Range(start:start, end:end))
    }
    
    func split(sep: String) -> [String] {
        return self.componentsSeparatedByString(sep)
    }
    
    func find(substr: String) -> Int? {
        if let range = self.rangeOfString(substr) {
            return distance(self.startIndex, range.startIndex)
        } else {
            return nil
        }
    }
    
    func findLast(substr: String) -> Int? {
        if let range = self.rangeOfString(substr, options:NSStringCompareOptions.BackwardsSearch) {
            return distance(self.startIndex, range.startIndex)
        } else {
            return nil
        }
    }
    
    func trimmed() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    func replace(before: String, after: String) -> String {
        return self.stringByReplacingOccurrencesOfString(before, withString: after)
    }
}

struct Lyc {
    static let manager = LycManager.sharedInstance
    
    var ti = ""
    var ar = ""
    var al = ""
    var by = ""
    var content: [String:String] = [:]
    
    init(data: String) {
        let arr = data.split("\r\n")
        for (index, str) in enumerate(arr) {
            if index < 4 {
                if str.find("ti:") != nil {
                    ti = str.substr(4, len: count(str) - 5)
                } else if str.find("ar:") != nil {
                    ar = str.substr(4, len: count(str) - 5)
                } else if str.find("al:") != nil {
                    al = str.substr(4, len: count(str) - 5)
                } else if str.find("by:") != nil {
                    by = str.substr(4, len: count(str) - 5)
                }
            } else {
                let key = str.substr(1, len: 8)
                let value = str.substr(10)
                content[key] = value
            }
        }
    }
    
    func getContentFrom(#minute: Int, second: Int) -> String? {
        let key = NSString(format: "%02d:%02d.00", minute, second) as String
        return content[key]
    }
}

class LycManager {
    internal static let sharedInstance: LycManager = {
        return LycManager()
    } ()
    
    var lycs:[String:Lyc] = [:]
    
    func cacheLyc(song: String, artist: String) {
        let url = "http://geci.me/api/lyric/\(song)/\(artist)"
        let utf8url = url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        if utf8url == nil {
            return
        }
        
        Alamofire.manager.request(Method.GET, utf8url!).responseJSON(options: NSJSONReadingOptions.MutableContainers,completionHandler: {
            (_, _, data, error) in
            if data == nil {
                return
            }
            let json = JSON(data!)
            let result:[JSON]? = json["result"].array
            if result == nil {
                return
            }
            
            for item in result! {
                let lrc = item["lrc"].string
                if let lrc_ = lrc {
                    if self.lycs.indexForKey(lrc_) != nil {
                        break
                    }
                    self.cacheLyc(lrc_)
                    break
                }
            }
        })
    }
    
    func cacheLyc(url: String) {
        if lycs.indexForKey(url) == nil {
            Alamofire.manager.request(.GET, url, parameters: nil).responseString(encoding:NSUTF8StringEncoding, completionHandler: {
                (request, response, data, error) in
                if let data_ = data {
                    self.lycs.updateValue(Lyc(data: data_), forKey: url)
                }
            })
        }
    }
    
}