//
//  Group.swift
//  mapkit-simple-v2
//
//  Created by HoangThai on 4/29/16.
//  Copyright © 2016 techmaster. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreLocation

class Group {
    
    var leaderEmail: String!
    var name: String!
    var photo: UIImage!
    var destination: CLLocationCoordinate2D!
    var description: String!
    var member_UIDs: [String]!
    
    init() {
        name = ""
        photo = UIImage()
        destination = CLLocationCoordinate2D()
        description = ""
        members_UID = [""]
    }
    
    init(leaderEmail: String, name: String, photo: UIImage, destination: CLLocationCoordinate2D, description: String, members_UIDs: [String]) {
        
        self.leaderEmail = leaderEmail
        self.name = name
        self.photo = photo
        self.destination = destination
        self.description = description
        self.member_UIDs = members_UIDs
        
    }
    
    func addMemberWithUID(uid: String) {
        self.member_UIDs.append(uid)
        DataService.instance.saveGroup(self)
    }
    
}