//
//  Request.swift
//  UberClone
//
//  Created by Marcelo Mogrovejo on 6/5/17.
//  Copyright © 2017 Marcelo Mogrovejo. All rights reserved.
//

import Foundation
import Parse

class Request {
    
    var username: String
    var location: PFGeoPoint
    var distance: Double
    
    init(username: String, location: PFGeoPoint, distance: Double) {
        self.username = username
        self.location = location
        self.distance = distance
    }
    
}
