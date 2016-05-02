//
//  miniTableViewCell.swift
//  mapkit-simple-v2
//
//  Created by HoangThai on 5/2/16.
//  Copyright © 2016 techmaster. All rights reserved.
//

import UIKit

class miniTableViewCell: UITableViewCell {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        photo.layer.cornerRadius = photo.frame.size.width / 2
        photo.clipsToBounds = true
        
        
    }

    func configureCell(person: Person) {
        
        let temp = person.email.componentsSeparatedByString("@")
        let name = temp[0]
        emailLabel.text = name
        photo.image = person.profilePhoto
    }
}
