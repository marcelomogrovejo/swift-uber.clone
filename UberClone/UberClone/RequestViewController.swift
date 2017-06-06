//
//  RequestViewController.swift
//  UberClone
//
//  Created by Marcelo Mogrovejo on 6/5/17.
//  Copyright © 2017 Marcelo Mogrovejo. All rights reserved.
//

import UIKit
import MapKit
import Parse

class RequestViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mainActionButton: UIButton!
    
    // MARK: Properties
    
    var request: Request!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Request coordinates
        let coordinate2D = CLLocationCoordinate2D(latitude: request.location.latitude, longitude: request.location.longitude)
        
        // Remove previows annotations if there are
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        // Zoom in
        let region = MKCoordinateRegion(center: coordinate2D, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
        
        // Show the request annotation or pin
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate2D
        annotation.title = request.username
        
        self.mapView.addAnnotation(annotation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Action methods
    
    @IBAction func mainAction(_ sender: Any) {
        
        let query = PFQuery(className: "RiderRequest")
        query.whereKey("username", equalTo: request.username)
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let riderRequests = objects {
                
                // TODO: check the first result if exist, then add label button to change and cancel the driverResponded to nil
                
                for riderRequest in riderRequests {
                    riderRequest["driverResponded"] = PFUser.current()?.username
                    riderRequest.saveInBackground()
                    
                    // Create directions and open map application
                    let requestCLLocation = CLLocation(latitude: self.request.location.latitude, longitude: self.request.location.longitude)
                    CLGeocoder().reverseGeocodeLocation(requestCLLocation, completionHandler: { (placemarks: [CLPlacemark]?, error: Error?) in
                        if let placemarks = placemarks {
                            if placemarks.count > 0 {
                                let mKPlacemark = MKPlacemark(placemark: placemarks[0])
                                let mapItem = MKMapItem(placemark: mKPlacemark)
                                mapItem.name = self.request.username
                                let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                                mapItem.openInMaps(launchOptions: launchOptions)
                            }
                        }
                    })
                }
            }
        }
    }
}
