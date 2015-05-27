//
//  ViewController.swift
//  dbfm
//
//  Created by tutujiaw on 15/5/19.
//  Copyright (c) 2015年 tujiaw. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, HttpProtocol, ChannelProtocol {

    @IBOutlet weak var iv: EkoImage!
    @IBOutlet weak var bg: UIImageView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var progress: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var orderButton: OrderButton!
    
    
    var httpCtrl = HttpController()
    var songData: [JSON] = []
    var channelData: [JSON] = []
    var songImage: [String:UIImage] = [:]
    var imageChache: [String:UIImage] = [:]
    var imageCount = 0
    var currentIndex = 0
    var isPlay = false
    var isAutoFinished = false
    
    let audioPlayer = MPMoviePlayerController()
    
    var timer:NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // 开始旋转
        iv.onRotation()
        // 背景模糊
        let blurEffect = UIBlurEffect(style: .Light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
        bg.addSubview(blurView)
        // 列表
        tv.dataSource = self
        tv.delegate = self
        // 透明
        tv.backgroundColor = UIColor.clearColor()
        // 监听播放结束
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onPlayFinished", name: MPMoviePlayerPlaybackDidFinishNotification, object: audioPlayer)
        
        httpCtrl.delegate = self
        httpCtrl.onSearch("http://www.douban.com/j/app/radio/channels")
        httpCtrl.onSearch("http://douban.fm/j/mine/playlist?type=n&channel=0&from=mainsite")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCellWithIdentifier("douban") as! UITableViewCell
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.text = getSongData(fromRow: indexPath.row, andKey: "title")
        cell.detailTextLabel?.text = getSongData(fromRow: indexPath.row, andKey: "artist")
        setImage(getSongData(fromRow: indexPath.row, andKey: "picture"), imgView: cell.imageView!)
        return cell
    }
    
    func onReceiveResults(results: AnyObject) {
        let json = JSON(results)
        if let channels = json["channels"].array {
            self.channelData = channels
        } else if let song = json["song"].array {
            self.songData = song
        }
        self.tv.reloadData()
    }
    
    func onPlayFinished() {
        if isAutoFinished == false {
            return
        }
        
        switch self.orderButton.order {
        case Order.Sequence: // 顺序播放
            ++currentIndex
            if currentIndex >= songData.count {
                currentIndex = 0
            }
            playMusic(currentIndex)
        case Order.Random: // 随机播放
            currentIndex = random() % songData.count
            playMusic(currentIndex)
        case Order.Cycle: // 单曲循环
            playMusic(currentIndex)
        default:
            println("onPlayFinished order error!")
        }
    }
    
    func getSongData(fromRow row: Int, andKey key: String) -> String? {
        let rowData = self.songData[row] as JSON
        return rowData[key].string
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currentIndex = indexPath.row
        setBackgroundImage(fromSelectedRow: indexPath.row)
        playMusic(currentIndex)
    }
    
    func setBackgroundImage(fromSelectedRow row: Int) {
        let indexPath = NSIndexPath(forRow: row, inSection: 0)
        tv.selectRowAtIndexPath(indexPath!, animated: false, scrollPosition: UITableViewScrollPosition.Top)
        let imgUrl = getSongData(fromRow: row, andKey: "picture")
        setImage(imgUrl, imgView: self.iv)
        setImage(imgUrl, imgView: self.bg)
    }
    
    func setImage(url: String?, imgView: UIImageView) {
        if url == nil {
            imgView.image = UIImage(named: "thumb")
            return
        }
        
        let opImg = self.imageChache[url!] as UIImage?
        if let img = opImg {
            imgView.image = img
        } else {
            imgView.image = UIImage(named: "thumb")
            Alamofire.manager.request(Method.GET, url!).response({
                (_, _, data, error) -> Void in
                let img = UIImage(data: data! as! NSData)
                imgView.image = img
                self.imageChache[url!] = img
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var channel = segue.destinationViewController as! ChannelController
        channel.delegate = self
        channel.data = self.channelData
    }
    
    func onChannelChanged(number: String) {
        let url = "http://douban.fm/j/mine/playlist?type=n&channel=\(number)&from=mainsite"
        httpCtrl.onSearch(url)
    }
    
    func playMusic(row: Int) {
        println("current:\(self.audioPlayer.currentPlaybackTime)")
        println("total:\(self.audioPlayer.duration)")
        
        isAutoFinished = true
        if !(self.audioPlayer.currentPlaybackTime.isNaN || self.audioPlayer.duration.isNaN) {
            let currentSecond = Int(self.audioPlayer.currentPlaybackTime)
            let totalSecond = Int(self.audioPlayer.duration)
            if currentSecond != totalSecond {
                isAutoFinished = false
            }
        }
        
        isPlay = true
        playButton.setImage(UIImage(named: "pause"), forState: .Normal)
        setBackgroundImage(fromSelectedRow: row)
        
        let prevIndexPath = NSIndexPath(forRow: row, inSection: 0)
        tv.selectRowAtIndexPath(prevIndexPath, animated: true, scrollPosition: .Top)
        
        self.audioPlayer.stop()
        self.audioPlayer.contentURL = NSURL(string: getSongData(fromRow: row, andKey: "url")!)
        self.audioPlayer.play()
        timer?.invalidate()
        timeLabel.text = "00:00"
        timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "onTimer", userInfo: nil, repeats: true)
    }
    
    func onTimer() {
        
        let time = audioPlayer.currentPlaybackTime
        let totalTime = audioPlayer.duration
        if time > 0.0 && totalTime > 0{
            let intTime = Int(time)
            let minute = intTime / 60
            let second = intTime % 60
            let formatTime = String("\(minute):\(second)")
            timeLabel.text = NSString(format: "%02d:%02d", minute, second) as String
            
            let percentage = CGFloat(time / totalTime)
            progress.frame.size.width = view.frame.size.width * percentage
        } else {
            timeLabel.text = "00:00"
        }
    }
    
    /////////////////////////////
    @IBAction func playClicked(sender: AnyObject) {
        isPlay = !isPlay
        if isPlay {
            playButton.setImage(UIImage(named: "pause"), forState: .Normal)
            self.audioPlayer.play()
        } else {
            playButton.setImage(UIImage(named: "play"), forState: .Normal)
            self.audioPlayer.pause()
        }
    }
    
    @IBAction func nextClicked(sender: AnyObject) {
        ++currentIndex
        if currentIndex >= songData.count {
            currentIndex = 0
        }
        playMusic(currentIndex)
    }
    
    @IBAction func prevClicked(sender: AnyObject) {
        --currentIndex
        if currentIndex < 0 {
            currentIndex = songData.count - 1
        }
        playMusic(currentIndex)
    }
    
    @IBAction func orderClicked(sender: AnyObject) {
        var tips = ["error", "顺序播放", "随机播放", "单曲循环", "error"]
        self.view.makeToast(message: tips[self.orderButton.order.rawValue], duration: 0.5, position: "center")
    }
    
    
}

