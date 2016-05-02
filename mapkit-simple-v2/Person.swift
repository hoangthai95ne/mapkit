//
//  Person.swift
//  mapkit-simple-v2
//
//  Created by HoangThai on 4/29/16.
//  Copyright © 2016 techmaster. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Firebase

class Person {
    
    var uid: String = ""
    var email: String = ""
    var profilePhoto = UIImage()
    var locationCoordinate = CLLocationCoordinate2D()
    
    init() {
        
        self.uid = ""
        self.email = ""
        self.profilePhoto = UIImage(named: "icon")!
        self.locationCoordinate = CLLocationCoordinate2DMake(21.027764, 105.83416)
    }
    
    init(uid: String, email: String, profilePhoto: UIImage, coordinate: CLLocationCoordinate2D) {
        
        self.uid = uid
        self.email = email
        self.profilePhoto = profilePhoto
        self.locationCoordinate = coordinate
        
    }
    
    class func personWithUID(uid: String, withBlock block: ((Person!) -> Void)!){
        
        var person = Person()
        person.uid = uid
        var locationLoaded = false
        var profilePhotoLoaded = false
        
        let personWithUID_Ref = Firebase(url: "\(FIREBASE_REF)/persons/\(uid)")
        let photoWithUID_Ref = Firebase(url: "\(FIREBASE_REF)/photos/\(uid)")
        
//        print("\(FIREBASE_REF)/persons/\(uid)")
        
        personWithUID_Ref.observeEventType(.Value, withBlock: { snapshot in 
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                var latitude = 0.0
                var longtitude = 0.0
                for snap in snapshots {
                    
                    switch snap.key {
                    case EMAIL: person.email = snap.value as! String
                    case LATITUDE: latitude = snap.value as! Double
                    case LONGTITUDE: longtitude = snap.value as! Double
                    default: break
                    }
                }
                person.locationCoordinate = CLLocationCoordinate2DMake(latitude, longtitude)
            }
            locationLoaded = true
            if profilePhotoLoaded {
                block(person)
            }
        })
        
        photoWithUID_Ref.observeEventType(.Value, withBlock: { snapshot in 
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    if let base64EncodedString = snap.value as? String {
                        if let base64Decoded = NSData(base64EncodedString: base64EncodedString, options:NSDataBase64DecodingOptions(rawValue: 0)) {
                            person.profilePhoto = UIImage(data: base64Decoded)!
                        }                        
                    }
                }
            }
            profilePhotoLoaded = true
            if locationLoaded {
                block(person)
            }
        })
    }
}