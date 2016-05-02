//
//  AuthorizationVC.swift
//  mapkit-simple-v2
//
//  Created by HoangThai on 4/28/16.
//  Copyright © 2016 techmaster. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class AuthorizationVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    let imagePicker = UIImagePickerController()
    
    var locationManager = CLLocationManager()
    let activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeImageViewToCircle(self.imageview)
        
        activity.center = self.view.center
        self.view.addSubview(activity)
        
        self.passwordTxt.delegate = self
        self.emailTxt.delegate = self
        
        locationManager.delegate = self
        if locationManager.respondsToSelector(#selector(CLLocationManager.requestWhenInUseAuthorization)) {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        
        //for status bar, but not sure
//        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        //status bar
//        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBarHidden = true
        
        //NSUserDefault
        if DataService.instance.signUpSuccessful {
            self.emailTxt.text = DataService.instance.tempEmail
            self.passwordTxt.text = DataService.instance.tempPassword
        }
        
    }
    
    //method status bar color
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
    
    //Text Field problems
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
//        if textField.frame.origin.y < 300 {
            scrollView.setContentOffset(CGPointMake(0, 100), animated: true)
//        }
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
    }
    
    
    //
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        
    }
    
    func makeImageViewToCircle(imageView1: UIImageView) {
        imageView1.layer.cornerRadius = imageView1.bounds.size.width / 2
        imageView1.clipsToBounds = true
    }
    
    @IBAction func addPicBtnPressed(sender: AnyObject) {
        
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
        
        self.imageview.image = image
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)        
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
        
    } 
    
    @IBAction func authorizationBtnPressed(sender: AnyObject) {
        
        self.startActivityView()
        
        scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
        
        if let email = emailTxt.text, let pwd = passwordTxt.text {
            
            DataService.instance.root_ref.authUser(email, password: pwd, withCompletionBlock: { error, authData in 
                
                if error != nil {
                    switch (error.code) {
                    case INVALID_EMAIL: self.showErrorAlert("Failed", msg: "Email address is invalid.")
                    case INVALID_USER: self.showErrorAlert("Failed", msg: "The username does not exist.")
                    case INVALID_PASSWORD: self.showErrorAlert("Failed", msg: "The password is incorrect.")
                    default: break
                    }
                    self.stopActivityView()
                } else {
                    
                    //for simulator
                    let currentCoordinate = CLLocationCoordinate2DMake(21.027764, 105.834160)
                    
                    //for devices
//                    let currentCoordinate = (self.locationManager.location?.coordinate)!
                    
                    let person = Person(uid: authData.uid, email: email, profilePhoto: self.imageview.image!, coordinate: CLLocationCoordinate2DMake(currentCoordinate.latitude, currentCoordinate.longitude))
                    
                    DataService.instance.savePerson(person)
                    DataService.instance.loggedInPerson = person
                    
                    //
                    self.stopActivityView()
                    //
                    self.performSegueWithIdentifier("showGroup", sender: nil)
                    //
                    
                    // test
                    // Print email
                    
//                    Person.personWithUID("49407100-c6a0-4cc7-b975-bb3552995f70", withBlock: { person in 
//                        print(person.email)
//                    })
                    
                    
                    //test
                    //1
                    
//                    DataService.instance.loadGroups(withBlock: { groups in 
//                        //nothing
//                    })
                    
                    //2
//                    let members_UIDs = [authData.uid!]
//                    let group = Group(leaderEmail: email, name: "HoangThai", photo: UIImage(named: "girl-3")!, destination: CLLocationCoordinate2DMake(currentCoordinate.latitude, currentCoordinate.longitude), description: "For fun", members_UIDs: members_UIDs)
//                    DataService.instance.saveGroup(group)
                    
//                    group.addMemberWithUID("db0c9db9-c3d7-4423-bb36-c544e9e78cbb")
                    
                    //another test
                    
//                    DataService.instance.loadGroups(withBlock: { group in 
//                        print(group.count)
//                    })
                    
                }
                
            })
        
            
            
        }
        
    }
    
    
    @IBAction func signUpBtnPressed(sender: AnyObject) {
        
        self.performSegueWithIdentifier("signUp", sender: nil)
        
    }
    
    
    
    
    
    
    
    
}
