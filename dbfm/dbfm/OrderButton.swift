//
//  OrderButton.swift
//  dbfm
//
//  Created by tutujiaw on 15/5/26.
//  Copyright (c) 2015年 tujiaw. All rights reserved.
//

import UIKit

class OrderButton: UIButton {
    var order: Int = 1
    
    let order1 = UIImage(named: "order1")!
    let order2 = UIImage(named: "order2")!
    let order3 = UIImage(named: "order3")!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: "onClicked:", forControlEvents: .TouchUpInside)
    }
    
    func onClicked(sender: UIButton) {
        ++order
        switch order {
        case 1:
            self.setImage(order1, forState: .Normal)
        case 2:
            self.setImage(order2, forState: .Normal)
        case 3:
            self.setImage(order3, forState: .Normal)
            order = 1
        default:
            println("order error!")
        }
    }
}
