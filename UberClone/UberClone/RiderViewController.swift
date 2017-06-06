//
//  RiderViewController.swift
//  UberClone
//
//  Created by Marcelo Mogrovejo on 6/2/17.
//  Copyright © 2017 Marcelo Mogrovejo. All rights reserved.
//

import UIKit
import Parse
import MapKit

class RiderViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: Properties
    
    var locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var isRiderActiveRequest: Bool = false
    var driverOnTheWay = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup user location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mainButton.setTitle("Call an Uber", for: [])
        messageLabel.isHidden = true
        
        // Check if there is active requests
        mainButton.isHidden = true
        
        let query = PFQuery(className: "RiderRequest")
        query.whereKey("username", equalTo: (PFUser.current()?.username)!)
        query.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
            
            if error != nil {
                
                // TODO
                
            } else {
                if (objects?.count)! > 0 {
                    self.isRiderActiveRequest = true
                    self.mainButton.setTitle("Cancel Uber", for: [])
                }
                self.mainButton.isHidden = false
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: CLLocationManagerDelegate methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Update and zoom in the current location
        if let location = manager.location?.coordinate {
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            if driverOnTheWay == false {
                
                let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                
                self.mapView.setRegion(region, animated: true)
                
                // Show the user annotation or pin
                self.mapView.removeAnnotations(self.mapView.annotations)
                let annotation = MKPointAnnotation()
                annotation.coordinate = userLocation
                annotation.title = "Your Location"
                
                self.mapView.addAnnotation(annotation)
            }

            // Update the location in parse
            let query = PFQuery(className: "RiderRequest")
            query.whereKey("username", equalTo: (PFUser.current()?.username)!)
            query.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                if error != nil {
                    
                    // TODO
                    
                } else {
                    if let riderRequests = objects {
                        for riderRequest in riderRequests {
                            riderRequest["location"] = PFGeoPoint(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                            riderRequest.saveInBackground()
                        }
                    }
                }
            })
        }
        
        
        
        if isRiderActiveRequest {
            let query = PFQuery(className: "RiderRequest")
            query.whereKey("username", equalTo: (PFUser.current()?.username)!)
            query.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                if let riderRequests = objects {
                    for riderRequest in riderRequests {
                        if let driverUsername = riderRequest["driverResponded"] {
                            let query = PFQuery(className: "DriverLocation")
                            query.whereKey("username", equalTo: driverUsername)
                            query.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                                if let driverLocations = objects {
                                    for driverLocationObject in driverLocations {
                                        if let driverLocation = driverLocationObject["location"] as? PFGeoPoint {
                                            
                                            self.driverOnTheWay = true
                                            
                                            let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                            let riderCLLocation = CLLocation(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                                            let distance = riderCLLocation.distance(from: driverCLLocation) / 1000
                                            let roundedDistance = round(distance * 100) / 100
                                            self.mainButton.setTitle("Your driver is \(roundedDistance)km away", for: [])
                                            
                                            // User location at the center of the map and zoom to see both, driver and rider
                                            let latitudeDelta = (driverLocation.latitude - self.userLocation.latitude) * 2 + 0.005
                                            let longitudeDelta = (driverLocation.longitude - self.userLocation.longitude) * 2 + 0.005
                                            
                                            self.mapView.removeAnnotation(self.mapView.annotations as! MKAnnotation)
                                            
                                            let region = MKCoordinateRegion(center: self.userLocation, span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
                                            self.mapView.setRegion(region, animated: true)
                                            
                                            let userLocationAnnotation = MKPointAnnotation()
                                            userLocationAnnotation.coordinate = self.userLocation
                                            userLocationAnnotation.title = "Your location"
                                            self.mapView.addAnnotation(userLocationAnnotation)
                                            
                                            let driverLocationAnnotation = MKPointAnnotation()
                                            driverLocationAnnotation.coordinate = CLLocationCoordinate2D(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                            driverLocationAnnotation.title = "Your driver"
                                            self.mapView.addAnnotation(driverLocationAnnotation)
                                            
                                        }
                                    }
                                }
                            })
                        }
                    }
                }
            })
            
            
        }
    }
    
    // MARK: Action methods
    
    @IBAction func mainAction(_ sender: Any) {
    
        if isRiderActiveRequest {
            
            isRiderActiveRequest = false
            mainButton.setTitle("Call an Uber", for: [])
            
            // Cancel a request
            let query = PFQuery(className: "RiderRequest")
            query.whereKey("username", equalTo: (PFUser.current()?.username)!)
            query.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                
                if error != nil {
                    
                    // TODO
                    
                } else {
                    if let riderRequests = objects {
                        for riderRequest in riderRequests {
                            riderRequest.deleteInBackground()
                        }
                    }
                }
            })
            
        } else {
        
            // Make a request
            isRiderActiveRequest = true
            self.mainButton.setTitle("Cancel Uber", for: [])
            
            if userLocation.latitude != 0 && userLocation.longitude != 0 {
                let riderRequest = PFObject(className: "RiderRequest")
                riderRequest["userId"] = PFUser.current()?.objectId
                riderRequest["username"] = PFUser.current()?.username
                riderRequest["location"] = PFGeoPoint(latitude: userLocation.latitude, longitude: userLocation.longitude)
                
                riderRequest.saveInBackground(block: { (success: Bool, error: Error?) in
                    if success {
                        print("Called an uber")

                        
                    } else {
                        self.messageLabel.isHidden = false
                        self.messageLabel.text = "Could not call Uber, please try again!"
                        
                        self.isRiderActiveRequest = false
                        self.mainButton.setTitle("Call an Uber", for: [])
                    }
                })
            } else {
                self.messageLabel.isHidden = false
                messageLabel.text = "Could not call Uber, cannot detect your location"
                
                isRiderActiveRequest = false
                mainButton.setTitle("Call an Uber", for: [])
            }
        }
    }

    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLogInFromRiderSegue" {
            // Stop updating location
            locationManager.stopUpdatingLocation()
            
            PFUser.logOut()
        }
    }

}
