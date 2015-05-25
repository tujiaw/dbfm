//
//  ChannelController.swift
//  dbfm
//
//  Created by tutujiaw on 15/5/23.
//  Copyright (c) 2015年 tujiaw. All rights reserved.
//

import UIKit

protocol ChannelProtocol {
    func onChannelChanged(id: String)
}

class ChannelController: UIViewController {

    @IBOutlet weak var tv: UITableView!
    var delegate: ChannelProtocol?
    var data: [JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.alpha = 0.8
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCellWithIdentifier("channel") as! UITableViewCell
        let rowData = self.data[indexPath.row] as JSON
        cell.textLabel?.text = rowData["name"].string
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let rowData = self.data[indexPath.row] as JSON
        let number = rowData["channel_id"].stringValue
        self.delegate?.onChannelChanged(number)
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
}
