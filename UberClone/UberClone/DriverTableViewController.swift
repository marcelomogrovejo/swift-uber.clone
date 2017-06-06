//
//  DriverTableViewController.swift
//  UberClone
//
//  Created by Marcelo Mogrovejo on 6/5/17.
//  Copyright © 2017 Marcelo Mogrovejo. All rights reserved.
//

import UIKit
import Parse
import MapKit

class DriverTableViewController: UITableViewController, CLLocationManagerDelegate {

    // MARK: Properties
    
    var requests = [Request]()
    var locationManager = CLLocationManager()
    var selectedRequest: Request!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
        // Setup user location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "requestCellId", for: indexPath) as! DriverTableViewCell

        let uberRequest = requests[indexPath.row]
        cell.configureCell(uberRequest: uberRequest)

        return cell
    }
    
    // MARK: CLLocationManagerDelegate methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Get current location
        if let location = manager.location?.coordinate {
            
            let driverLocationPoint = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
            
            let driverLocationQuery = PFQuery(className: "DriverLocation")
            driverLocationQuery.whereKey("username", equalTo: (PFUser.current()?.username)!)
            driverLocationQuery.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                if let driverLocations = objects {
                    
                    for driverLocation in driverLocations {
                        driverLocation.deleteInBackground()
                    }
                    let driverLocation = PFObject(className: "DriverLocation")
                    driverLocation["username"] = PFUser.current()?.username
                    driverLocation["location"] = driverLocationPoint
                    driverLocation.saveInBackground()
                }
            })
            
            
            
            let query = PFQuery(className: "RiderRequest")
            query.whereKey("location", nearGeoPoint: driverLocationPoint)
            query.limit = 10
            query.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                
                if let riderRequests = objects {
                    if riderRequests.count > 0 {
                        self.requests.removeAll()
                        for riderRequest in riderRequests {
                            
                            if riderRequest["driverResponded"] == nil {
                                let requestUsername = riderRequest["username"] as! String
                                let toLocation = riderRequest["location"] as! PFGeoPoint
                                let distanceInKilometers = driverLocationPoint.distanceInKilometers(to: toLocation)

                                self.requests.append(Request(username: requestUsername, location: toLocation, distance: distanceInKilometers))
                            }
                        }
                        self.tableView.reloadData()
                    }
                }
            })

        
        }
        
    }
    
    // MARK: Action methods
    
    @IBAction func logout(_ sender: Any) {
        locationManager.stopUpdatingLocation()
        PFUser.logOut()
        performSegue(withIdentifier: "showLogInFromDriverSegue", sender: self)
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "showRequestDetailSegue") {
            let requestController = segue.destination as! RequestViewController
            let selectedRow = tableView.indexPathForSelectedRow?.row
            requestController.request = requests[selectedRow!]
        }
    }

}
