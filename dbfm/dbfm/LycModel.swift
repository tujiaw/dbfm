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
        if pos + len > count(self) {
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


class Lyric {
    var ti:String = ""
    var ar: String = ""
    var al: String = ""
    var by: String = ""
    var content: [String:String] = [:]
    
    init(data: String) {
        let arr = data.split("\r\n")
        for (index, str) in enumerate(arr) {
            var notFind = false
            if index < 4 {
                let num = count(str) - 5
                if str.find("ti:") != nil {
                    ti = (num <= 0) ? "" : str.substr(4, len: num)
                } else if str.find("ar:") != nil {
                    ar = (num <= 0) ? "" : str.substr(4, len: num)
                } else if str.find("al:") != nil {
                    al = (num <= 0) ? "" : str.substr(4, len: num)
                } else if str.find("by:") != nil {
                    by = (num <= 0) ? "" : str.substr(4, len: num)
                } else {
                    notFind = true
                }
            } else {
                notFind = true
            }
            
            if notFind {
                var start = str.find("[")
                var end = str.findLast("]")
                if start == nil || end == nil {
                    continue
                }
                
                var key = str.substr(1, len: end! - 1)
                var value = str.substr(end! + 1)
                if count(key) < 5 {
                    continue
                }
                
                if key.find("][") != nil {
                    let keys = key.split("][")
                    for item in keys {
                        let tm = item.substr(0, len: 5)
                        if !tm.isEmpty {
                            content[tm] = value
                        }
                    }
                } else {
                    let tm = key.substr(0, len: 5)
                    if !tm.isEmpty {
                        content[tm] = value
                    }
                }
            }
        }
    }
    
    func getContent(#minute: Int, second: Int) -> String? {
        let key = NSString(format: "%02d:%02d", minute, second) as String
        return self.content[key]
    }
}

class LyricManager {
    class var instance: LyricManager {
        struct Static {
            static let instance = LyricManager()
        }
        return Static.instance
    }
    
    var current: Lyric?
    
    func cacheLyc(song: String, artist: String) {
        current = nil
        let specialHandle = {
            (str: String) -> String in
            var result = str
            for (i, a) in enumerate(str) {
                if a == "(" || a == "（" || a == "&" || a == "/" {
                    result = str.substr(0, len: i)
                    break
                }
            }
            return result.trimmed()
        }
        
        let searchSong = specialHandle(song)
        let searchArtist = specialHandle(artist)
        let url = "http://geci.me/api/lyric/\(searchSong)/\(searchArtist)"
        println("url:\(url)")
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
                if lrc != nil {
                    self.cacheLyc(lrc!)
                    break
                }
            }
        })
    }
    
    func cacheLyc(url: String) {
        Alamofire.manager.request(.GET, url, parameters: nil).responseString(encoding:NSUTF8StringEncoding, completionHandler: {
            (request, response, data, error) in
            let url = request.URL?.absoluteString
            if data != nil {
                println(data!)
                self.current = Lyric(data: data!)
            }
        })
    }
}
