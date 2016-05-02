//
//  NewGroupVC.swift
//  mapkit-simple-v2
//
//  Created by HoangThai on 5/1/16.
//  Copyright © 2016 techmaster. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class NewGroupVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profilePhoto: UIImageView!
    
    @IBOutlet weak var groupNameTxt: UITextField!
    
    @IBOutlet weak var descriptionTxt: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var locationStringTxt: UITextField!
    
    var geoCoder = CLGeocoder()
    
    let imagePicker = UIImagePickerController()
    
    var groupDestination = CLLocationCoordinate2D()
    
    var group = Group()
    
    let activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.mapType = .Standard
        self.locationStringTxt.delegate = self
        self.locationStringTxt.clearButtonMode = .Always
        
        self.descriptionTxt.delegate = self
        self.groupNameTxt.delegate = self
        
//        self.makeImageViewToCircle(self.profilePhoto)
        self.profilePhoto.clipsToBounds = true
    
        self.title = "New Group"
        
    }
    
    //activityView
    func startActivityView() {
        activity.hidden = false
        activity.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    func stopActivityView() {
        activity.hidden = true
        activity.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    
    func makeImageViewToCircle(imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.bounds.size.width / 2
        imageView.clipsToBounds = true
    }
    
    @IBAction func submitBtnPressed(sender: AnyObject) {
        
        var checkGroupIsAlreadyExist = false
        for _group in DataService.instance.loadedGroups {
            if (self.group.leaderEmail == _group.leaderEmail) {
                checkGroupIsAlreadyExist = true
            }
        }
        
        if checkGroupIsAlreadyExist {
            self.showErrorAlert("Something wrong", msg: "your email have created a Group, it will be replace")
            DataService.instance.saveGroup(self.group)
//            self.navigationController?.popViewControllerAnimated(true)
        } else {
            self.showErrorAlert("Success", msg: "your team have created")
            DataService.instance.saveGroup(self.group)
//            self.navigationController?.popViewControllerAnimated(true)
        }
        
        

    }
    
    @IBAction func photoBtnPressed(sender: AnyObject) {
        imagePicker.delegate = self
        sender.setTitle("", forState: .Normal)
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let action0 = UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in 
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        
        let action1 = UIAlertAction(title: "Photo Library", style: .Default) { action in
            self.imagePicker.sourceType = .SavedPhotosAlbum
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        
        let action2 = UIAlertAction(title: "Camera", style: .Default) { action in
            if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
                self.imagePicker.sourceType = .Camera
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            } else {
                self.showErrorAlert("Error", msg: "Camera is not available")
            }
        }
        
        alert.addAction(action0)
        alert.addAction(action1)
        alert.addAction(action2)
        
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRectMake(sender.frame.origin.x, sender.frame.origin.y, alert.view.bounds.size.width, alert.view.bounds.size.height)
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.profilePhoto.image = image
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)        
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
        
    } 
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.endEditing(true)
        
        if textField == (self.locationStringTxt)! {
            
            self.startActivityView()
            
            self.geoCoder.geocodeAddressString(self.locationStringTxt.text!) { (placemarks, error) in
                
                if error != nil {
                    self.showErrorAlert("Error", msg: "Couldn't find location, try another")
                    self.stopActivityView()
                } else {
                    let foundPlace = placemarks![0]
                    self.updateMapView((foundPlace.location?.coordinate)!)
                    let foundPin = MKPointAnnotation()
                    foundPin.coordinate = (foundPlace.location?.coordinate)!
                    foundPin.title = foundPlace.description
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    self.mapView.addAnnotation(foundPin)
                    
                    //create Group
                    self.groupDestination = (foundPlace.location?.coordinate)!
                    let groupName = self.groupNameTxt.text
                    let description = self.descriptionTxt.text
                    
                    let loggedInPerson = DataService.instance.loggedInPerson
                    let leaderEmail = loggedInPerson.email
                    let members_UIDs = [loggedInPerson.uid]
                    
                    self.group = Group(leaderEmail: leaderEmail, name: groupName!, photo: self.profilePhoto.image!, destination: self.groupDestination, description: description!, members_UIDs: members_UIDs)
                    
                }
            }
        }
        
        return true
    
    }
    
    func emailWithNoDotCom(email: String) -> String {
        
        let index = email.endIndex.advancedBy(-4)
        let newEmailAddress = email.substringToIndex(index)
        
        return newEmailAddress
    }
    
    func updateMapView(coordinate: CLLocationCoordinate2D) {
        
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegionMake(coordinate, span)
        self.mapView.setRegion(region, animated: true)
        
        self.stopActivityView()
        
    }
    
    
    
    
    
    
    
    
    
    
}
