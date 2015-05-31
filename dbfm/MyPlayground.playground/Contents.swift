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

var lyc = "[ti:忽然之间]\r\n[ar:莫文蔚]\r\n[00:15.93]忽然之间 天昏地暗\r\n[00:23.00]世界可以忽然什么都没有\r\n[00:29.98]我想起了你 再想到自己\r\n[00:36.29]我为什么总在非常脆弱的时候 怀念你\r\n[02:36.37][01:43.02][00:45.21]我明白太放不开你的爱 太熟悉你的关怀\r\n[02:45.04][01:51.11][00:53.79]分不开 想你算是安慰还是悲哀\r\n[02:50.38][01:56.61[00:59.11]而现在 就算时针都停摆 就算生命像尘埃\r\n[02:59.08][02:05.02][01:07.73]分不开 我们也许反而更相信爱\r\n[03:08.72][01:14.63][01:26.80]如果这天地 终会消失\r\n[01:34.04]不想一路走来珍惜的回忆 没有你\r\n[02:55.80]"


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
                if start != nil && end != nil {
                    var key = str.substr(1, len: end! - 1)
                    var value = str.substr(end! + 1)
                    if count(key) < 8 {
                        return
                    }
                    
                    if key.find("][") != nil {
                        let keys = key.split("][")
                        for item in keys {
                            if count(item) >= 8 {
                                let tm = item.substr(0, len: 5)
                                if !tm.isEmpty {
                                    content[tm] = value
                                }
                            }
                        }
                    } else {
                        key = key.substr(0, len: 5)
                        if !key.isEmpty {
                            content[key] = value
                        }
                    }
                }
            }
        }
    }
    
    func getContent(#minute: Int, second: Int) -> String? {
        let key = NSString(format: "%02d:%02d.00", minute, second) as String
        return content[key]
    }
}

class LyricManager {
    class var instance: LyricManager {
        struct Static {
            static let instance = LyricManager()
        }
        return Static.instance
    }
    
    var data: [String:Lyric] = [:]
}

let x = Lyric(data: lyc)
