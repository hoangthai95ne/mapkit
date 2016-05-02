//
//  DetailGroupVC.swift
//  mapkit-simple-v2
//
//  Created by HoangThai on 5/1/16.
//  Copyright © 2016 techmaster. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import CoreLocation

class DetailGroupVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate {
    
    
    @IBOutlet weak var groupPhoto: UIImageView!
    
    @IBOutlet weak var descLbl: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var group = Group()
    
    var members = [Person]()
    
    var locationManager = CLLocationManager()
    var geoCoder = CLGeocoder()
    var direction = MKDirections?()
    
    var currentLocation: CLLocationCoordinate2D?
    
    var overLay = MKOverlay?()
    
    var person = Person?()
    
    var coordinate = CLLocationCoordinate2D()
    
    var destination = CLLocationCoordinate2D()
    
    let activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    var once = false //for activityView
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        mapView.delegate = self
        
        locationManager.delegate = self
        
        if (locationManager.respondsToSelector(#selector(CLLocationManager.requestWhenInUseAuthorization))) {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        
        for uid in group.member_UIDs {
            Person.personWithUID(uid, withBlock: { person in
                self.members.append(person)
                self.tableView.reloadData()
            })
        }
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
        
        self.groupPhoto.image = group.photo
        makeImageViewToCircle(groupPhoto)
        
        descLbl.text = group.description
        
        self.title = group.name
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.activity.center = self.mapView.center
        self.view.addSubview(self.activity)        
    }
    
    func makeImageViewToCircle(imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.bounds.size.width / 2
        imageView.clipsToBounds = true
    }

    @IBAction func joinGroupBtnPressed(sender: AnyObject) {
        
        let loggedInPerson = DataService.instance.loggedInPerson
        
        var checkMember = false
        
        for member in members {
            if member.uid == loggedInPerson.uid {
                checkMember = true
            }
        }
        
        if checkMember {
            self.showErrorAlert("Failed", msg: "You have joined this group")
        } else {
            self.showErrorAlert("Success", msg: "you joined")
            group.addMemberWithUID(loggedInPerson.uid)
            self.members.append(loggedInPerson)
            self.tableView.reloadData()
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let person = members[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("detailGroupCell") as? miniTableViewCell {
            cell.configureCell(person)
            return cell
        } else {
            let cell = miniTableViewCell()
            cell.configureCell(person)
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let member = members[indexPath.row]
        
        currentLocation = locationManager.location?.coordinate
        
        let fromPlace = MKPlacemark(coordinate: currentLocation!, addressDictionary: nil)
        let toPlace = MKPlacemark(coordinate: member.locationCoordinate, addressDictionary: nil)
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.removeOverlay(self.overLay!)
        self.routePath(fromPlace, toPlace: toPlace)
        
    }
    
    @IBAction func imageBtnPressed(sender: AnyObject) {
        
        sender.setTitle("", forState: .Normal)
        
        let currentLocation = locationManager.location?.coordinate
        let fromPlace = MKPlacemark(coordinate: currentLocation!, addressDictionary: nil)
        let toPlace = MKPlacemark(coordinate: (self.group.destination)!, addressDictionary: nil)
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.removeOverlay(self.overLay!)
        self.routePath(fromPlace, toPlace: toPlace)
        
    }

    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)        
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
        
    } 


    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.stopUpdatingLocation()
        
        let currentLocation = locationManager.location?.coordinate
        let fromPlace = MKPlacemark(coordinate: currentLocation!, addressDictionary: nil)
        let toPlace = MKPlacemark(coordinate: (self.group.destination)!, addressDictionary: nil)
        self.routePath(fromPlace, toPlace: toPlace)
        
        let location: CLLocation = locations[locations.count - 1]
        let theRegion: MKCoordinateRegion = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.01, 0.01))
        self.mapView.setRegion(theRegion, animated: true)
        
    }
    
    
    //Route Path
    
    func routePath(fromPlace: MKPlacemark, toPlace: MKPlacemark) {
        
        once = true
        self.startActivityView()
//        print("start")
        
        let request = MKDirectionsRequest()
        
        let fromItemMap = MKMapItem(placemark: fromPlace)
        request.source = fromItemMap
        
        let toMapItem = MKMapItem(placemark: toPlace)
        request.destination = toMapItem
        
        direction = MKDirections(request: request)
        
        direction!.calculateDirectionsWithCompletionHandler { (response, error) in
            
            if error != nil {
                print(error)
            } else {
                self.mapSetRegion(fromPlace.coordinate, toPoint: toPlace.coordinate)
                self.destination = toPlace.coordinate
                self.showRoute(response!)
            }
            
        }
        
        
    }
    
    func mapSetRegion(fromPoint: CLLocationCoordinate2D, toPoint: CLLocationCoordinate2D) {
        
        let centerPoint = CLLocationCoordinate2DMake((fromPoint.latitude + toPoint.latitude) / 2, (fromPoint.longitude + toPoint.longitude) / 2)
        
        var latitudeDelta = (fromPoint.latitude - toPoint.latitude) * 1.5
        
        if latitudeDelta < 0 { latitudeDelta = -1 * latitudeDelta }
        
        var longtitudeDelta = (fromPoint.longitude - toPoint.longitude) * 1.5
        
        if longtitudeDelta < 0 { longtitudeDelta = -1 * longtitudeDelta }
        
        let span = MKCoordinateSpanMake(latitudeDelta, longtitudeDelta)
        
        let region = MKCoordinateRegionMake(centerPoint, span)
        
        self.mapView.setRegion(region, animated: true)
    }
    
    func showRoute(response: MKDirectionsResponse) {
        
        let toAnnotation = MKPointAnnotation()
        toAnnotation.coordinate = self.destination
        
        self.mapView.addAnnotation(toAnnotation)
        
        
        for route in response.routes {
            
            self.overLay = route.polyline
            self.mapView.addOverlay(self.overLay!, level: .AboveRoads)
            
            //once not working, don't mind
//            if once {
                once = false
//                print("done")
                self.stopActivityView()
//            }
        
        }
        
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 5.0
        
        return renderer
        
    }











}
