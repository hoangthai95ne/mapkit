//
//  SignUpVC.swift
//  mapkit-simple-v2
//
//  Created by HoangThai on 5/2/16.
//  Copyright © 2016 techmaster. All rights reserved.
//

import UIKit
import Firebase

class SignUpVC: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var emailTxt: TJTextField!
    
    @IBOutlet weak var passwordTxt: TJTextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    let activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activity.center = self.view.center
        self.view.addSubview(activity)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
        self.emailTxt.delegate = self
        self.passwordTxt.delegate = self
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func signUpBtnPressed(sender: AnyObject) {
        
        self.startActivityView()
        
        self.scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
        
        let rootRef = Firebase(url: FIREBASE_REF)
        
        if let email = emailTxt.text, pwd = passwordTxt.text {
            
            var checkEmail = true
            for char in self.emailWithNoDotCom(email).characters {
                switch char {
                case ".": checkEmail = false
                case "#": checkEmail = false
                case "$": checkEmail = false
                case "[": checkEmail = false
                case "]": checkEmail = false
                default: break
                }
            }
            
            if checkEmail {
                
                rootRef.createUser(email, password: pwd, withCompletionBlock: { error in 
                    if error != nil {
                        switch error.code {
                        case EMAIL_TAKEN: self.showErrorAlert("Error", msg: "Email is already signed up") 
                        case INVALID_EMAIL: self.showErrorAlert("Failed", msg: "Email address is invalid.")
                        default: break
                        }
                    } else {
                        self.showErrorAlert("Success", msg: "create successful")
                        DataService.instance.signUpSuccessful = true
                        DataService.instance.tempEmail = email
                        DataService.instance.tempPassword = pwd
                    }
                    
                })
            } else {
                self.showErrorAlert("Error", msg: "email must not contain '.' '#' '$' '[' or ']''")
            }
            self.stopActivityView()
        }
    }
    
    func emailWithNoDotCom(email: String) -> String {
        
        let index = email.endIndex.advancedBy(-4)
        let newEmailAddress = email.substringToIndex(index)
        
        return newEmailAddress
    }
    
    //text field problems
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
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)        
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
        
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
    
    @IBAction func doneBtnPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
