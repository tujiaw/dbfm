//
//  OrderButton.swift
//  dbfm
//
//  Created by tutujiaw on 15/5/26.
//  Copyright (c) 2015年 tujiaw. All rights reserved.
//

import UIKit

enum Order: Int {
    case Sequence = 1
    case Random
    case Cycle
    case Unknown
}
xxxx
class OrderButton: UIButton {
    var order = Order.Sequence
    
    let order1 = UIImage(named: "order1")!
    let order2 = UIImage(named: "order2")!
    let order3 = UIImage(named: "order3")!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: "onClicked:", forControlEvents: .TouchUpInside)
    }
    
    func onClicked(sender: UIButton) {
        switch order {
        case Order.Sequence:
            order = Order.Random
            self.setImage(order2, forState: .Normal)
        case Order.Random:
            order = Order.Cycle
            self.setImage(order3, forState: .Normal)
        case Order.Cycle:
            order = Order.Sequence
            self.setImage(order1, forState: .Normal)
        default:
            println("order error!")
        }
    }
}
