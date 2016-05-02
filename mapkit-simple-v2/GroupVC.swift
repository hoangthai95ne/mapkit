//
//  GroupVC.swift
//  mapkit-simple-v2
//
//  Created by HoangThai on 5/1/16.
//  Copyright © 2016 techmaster. All rights reserved.
//

import UIKit

class GroupVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var groups = [Group]()
    
    let activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activity.center = self.view.center
        self.view.addSubview(self.activity)
        self.startActivityView()
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "mk-groups"
        
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = .Black
        
        
        //        let barTintColor = UIColor(red: 38 / 255, green: 181 / 255, blue: 255 / 255, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = UIColor.clearColor()       
        
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(GroupVC.rightBarBtnPressed))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        var once = true
        DataService.instance.loadGroups(withBlock: { loadedGroups in 
            self.groups = loadedGroups
            self.tableView.reloadData()
            if once {
                self.stopActivityView()
                once = false
            }
        })
        
        
        
    }
    
    //Right Bar Button
    
    func rightBarBtnPressed() {
        
        self.performSegueWithIdentifier("newGroup", sender: nil)
        
    }
    
    //TableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let groupAtIndexPath = groups[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("groupCell") as? MaterialCell {
            cell.configureCell(groupAtIndexPath)
            return cell
        } else {
            let cell = MaterialCell()
            cell.configureCell(groupAtIndexPath)
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    
    
    //    showDetailGroup
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetailGroup" {
            let detail = segue.destinationViewController as! DetailGroupVC
            detail.group = groups[(tableView.indexPathForSelectedRow?.row)!]
        }
    }
    
    
    
    
    
    
    
    
    
    
}
