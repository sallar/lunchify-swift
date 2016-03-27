//
//  Venue.swift
//  Lunchify
//
//  Created by Sallar Kaboli on 11/22/15.
//  Copyright © 2015 Sallar Kaboli. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation
import MapKit

struct Venue {
    
    // Venue properties
    let id: String
    var name: String?
    var simpleName: String?
    var address: String?
    var latitude: Double?
    var longitude: Double?
    var location: CLLocation?
    
    // Helpers
    let distanceFormatter = MKDistanceFormatter()
    
    init(venue: JSON) {
        id = venue["_id"].string!
        name = venue["name"].string
        address = venue["address"].string
        latitude = venue["location"]["coordinates"][1].double
        longitude = venue["location"]["coordinates"][0].double
        simpleName = venue["simple_name"].string
        
        // Make a CoreLocation object 
        if let lat = latitude, let long = longitude {
            location = CLLocation(latitude: lat, longitude: long)
        }
        
        // Distance Config
        distanceFormatter.units = .Metric
        distanceFormatter.unitStyle = .Abbreviated
    }
    
    func distanceFromLocation(location: CLLocation) -> String? {
        var distanceString: String?
        
        if let venueLocation = self.location {
            let distance = location.distanceFromLocation(venueLocation)
            distanceString = distanceFormatter.stringFromDistance(distance)
        }
        
        return distanceString
    }
    
}