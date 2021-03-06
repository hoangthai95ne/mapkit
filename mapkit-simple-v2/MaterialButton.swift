//
//  MaterialButton.swift
//  MyNeighbour
//
//  Created by HoangThai on 4/18/16.
//  Copyright © 2016 techmaster. All rights reserved.
//

import UIKit

class MaterialButton: UIButton {

    override func awakeFromNib() {
        
        layer.cornerRadius = 20
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5
        clipsToBounds = true
        layer.shadowOffset = CGSizeMake(0.0, 2.0)
        
    }

}
