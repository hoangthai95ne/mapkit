//
//  DataService.swift
//  mapkit-simple-v2
//
//  Created by HoangThai on 4/28/16.
//  Copyright © 2016 techmaster. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Firebase

class DataService {
    
    static var instance = DataService()
    
    var root_ref = Firebase(url: FIREBASE_REF)
    let photo_Ref = Firebase(url: FIREBASE_REF).childByAppendingPath("photos")
    let person_Ref = Firebase(url: FIREBASE_REF).childByAppendingPath("persons")
    let group_Ref = Firebase(url: FIREBASE_REF).childByAppendingPath("groups")
    
    var loadedGroups = [Group]()
    var loadedPersons = [Person]()
    var loggedInPerson = Person()
    
    var signUpSuccessful = false
    var tempEmail = ""
    var tempPassword = ""
    
    func savePerson(person: Person) {
        
        person.profilePhoto = resizeImage(person.profilePhoto, newWidth: 200)
        
        let imageData: NSData = UIImagePNGRepresentation(person.profilePhoto)!
        let base64String = imageData.base64EncodedStringWithOptions([])
        
        let person_UID = person_Ref.childByAppendingPath("\(person.uid)")
        let personDict = [EMAIL: person.email, LATITUDE: person.locationCoordinate.latitude, LONGTITUDE: person.locationCoordinate.longitude]
        person_UID.setValue(personDict)
        
        let photo_UID = photo_Ref.childByAppendingPath("\(person.uid)")
        let photoDict = [PERSON_PROFILE_PHOTO: base64String]
        photo_UID.setValue(photoDict)
        
    }
    
    func saveGroup(group: Group) {
        
        group.photo = resizeImage(group.photo, newWidth: 200)
        let imageData: NSData = UIImagePNGRepresentation(group.photo)!
        let base64String = imageData.base64EncodedStringWithOptions([])
        
        let group_ID = group_Ref.childByAppendingPath("\(emailWithNoDotCom(group.leaderEmail))")
        let groupDict = [GROUP_NAME: group.name, GROUP_DESTINATION_LATITUDE: group.destination.latitude, GROUP_DESTINATION_LONGTITUDE: group.destination.longitude, GROUP_DESCRIPTION: group.description]
        group_ID.setValue(groupDict)
        
        let member_Ref = group_ID.childByAppendingPath(GROUP_MEMBERS_UIDS)
        member_Ref.setValue(group.member_UIDs as [String])
        
        if group.member_UIDs.count == 1 {
            let photo_group = photo_Ref.childByAppendingPath("\(emailWithNoDotCom(group.leaderEmail))")
            let photoDict = [GROUP_PROFILE_PHOTO: base64String]
            photo_group.setValue(photoDict)
        }
        
    }
    
    func emailWithNoDotCom(email: String) -> String {
        
        let index = email.endIndex.advancedBy(-4)
        let newEmailAddress = email.substringToIndex(index)
        
        return newEmailAddress
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func loadGroups(withBlock block: (([Group]!) -> Void)!) {
        
        self.group_Ref.observeEventType(.Value, withBlock: { snapshot in
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                self.loadedGroups = []
                for snap in snapshots {
                    if let groupDict = snap.value as? Dictionary<String, AnyObject> {
                        
                        let key = snap.key
                        let destination = CLLocationCoordinate2DMake((groupDict[GROUP_DESTINATION_LATITUDE]?.doubleValue)!, (groupDict[GROUP_DESTINATION_LONGTITUDE]?.doubleValue)!)
                        
                        //member_uids
                        let member_UIDs_Ref = Firebase(url: "\(FIREBASE_REF)/groups/\(key)/member_UIDs")
                        member_UIDs_Ref.observeEventType(.Value, withBlock: { snapshot1 in 
                            
                            var member_UIDs = [String]()
                            
                            if let snapshots1 = snapshot1.children.allObjects as? [FDataSnapshot] {
                                for snap1 in snapshots1 {
                                    member_UIDs.append(snap1.value as! String)
                                }
                                var groupPhoto = UIImage()
                                
                                self.loadPhotoWithKey(key, withBlock: { image in 
                                    groupPhoto = image
                                    let group = Group(leaderEmail: "\(key).com", name: groupDict[GROUP_NAME] as! String, photo: groupPhoto, destination: destination, description: groupDict[GROUP_DESCRIPTION] as! String, members_UIDs: member_UIDs)
                                    self.loadedGroups.append(group)
                                    
                                    //block
                                    block(self.loadedGroups)
                                    
                                })
                                
                            }
                        })
                        
                        
                        
                    }
                }
            }
        })
    }
    
    func loadPhotoWithKey(key: String, withBlock block: ((UIImage!) -> Void)!) {
        
        var image = UIImage()
        self.photo_Ref.observeEventType(.Value, withBlock: {snapshot in 
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    if snap.key == key {
                        if let valueDict = snap.value as? Dictionary<String, String> {
                            if let base64Decoded = NSData(base64EncodedString: valueDict[GROUP_PROFILE_PHOTO]!, options: NSDataBase64DecodingOptions(rawValue: 0)) {
                                image = UIImage(data: base64Decoded)!
                                
                            }
                        }
                    }
                }
                
                block(image)
                
            }
        })
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}