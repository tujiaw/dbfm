println("hi there")
//Runs automatically. Just start typing.
//See "About" for shortcuts


extension String {
    func substr(pos: Int, len: Int = 0) -> String {
        if pos + len > countElements(self) {
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

var lyc = "[ti:相见恨晚]\r\n[ar:彭佳慧]\r\n[al:敲敲我的头]\r\n[by:wz (http://www.lotof.com/lyrics)]\r\n[00:00.00]相见恨晚    词∶娃娃　曲∶陈国华\r\n[00:36.00]你有一张好陌生的脸\r\n[00:39.00]到今天才看见\r\n[00:44.00]有点心酸在我们之间\r\n[00:48.00]如此短暂的情缘\r\n[00:52.00]看著天空不让泪流下\r\n[00:56.00]不说一句埋怨\r\n[01:00.00]只是心中的感概万千\r\n[01:04.00]当作前世来生相欠\r\n[01:08.00]你说是我们相见恨晚\r\n[01:12.00]我说为爱你不够勇敢\r\n[01:17.00]我不奢求永远\r\n[01:19.00]永远太遥远\r\n[01:21.00]却陷在爱的深渊\r\n[01:25.00]你说是我们相见恨晚\r\n[01:29.00]我说为爱你不够勇敢\r\n[01:34.00]在爱与不爱间\r\n[01:36.00]来回千万遍\r\n[01:38.00]哪怕已伤痕累累　我也不管\r\n[01:46.00](music)\r\n[02:00.00]你有一张好陌生的脸\r\n[02:03.00]到今天才看见\r\n[02:08.00]有点心酸在我们之间\r\n[02:12.00]如此短暂的情缘\r\n[02:16.00]看著天空不让泪流下\r\n[02:20.00]不说一句埋怨\r\n[02:24.00]只是心中的感概万千\r\n[02:28.00]当作前世来生相欠\r\n[02:32.00]你说是我们相见恨晚\r\n[02:36.00]我说为爱你不够勇敢\r\n[02:41.00]我不奢求永远\r\n[02:43.00]永远太遥远\r\n[02:45.00]却陷在爱的深渊\r\n[02:49.00]你说是我们相见恨晚\r\n[02:53.00]我说为爱你不够勇敢\r\n[02:58.00]在爱与不爱间\r\n[03:00.00]来回千万遍\r\n[03:02.00]哪怕已伤痕累累　我也不管\r\n[03:10.00]你说是我们相见恨晚\r\n[03:14.00]我说为爱你不够勇敢\r\n[03:19.00]我不奢求永远\r\n[03:21.00]永远太遥远\r\n[03:23.00]却陷在爱的深渊\r\n[03:27.00]你说是我们相见恨晚\r\n[03:31.00]我说为爱你不够勇敢\r\n[03:36.00]在爱与不爱间\r\n[03:38.00]来回千万遍\r\n[03:40.00]哪怕已伤痕累累　我也不管\r\n[03:49.00]\r\nWelcome to http://www.lotof.com/lyrics\n"


struct Lyric {
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
                let num = countElements(str) - 5
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
                if str.find("[") != nil && str.find("]") != nil {
                    let key = str.substr(1, len: 8)
                    let value = str.substr(10)
                    content[key] = value   
                }
            }
        }
    }
    
    func getContent(#minute: Int, second: Int) -> String? {
        let key = NSString(format: "%02d:%02d.00", minute, second) as String
        return content[key]
    }
}

let x = Lyric(data: lyc)
let y = x.getContent(minute: 0, second: 39)
for (time, content) in x.content {
    println("\(time), \(content)")
}
