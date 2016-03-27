//
//  VenuesService.swift
//  Lunchify
//
//  Created by Sallar Kaboli on 11/22/15.
//  Copyright © 2015 Sallar Kaboli. All rights reserved.
//

import Foundation
import CoreLocation

struct VenuesService {
    
    let apiBaseURL: String = "http://lunchify:8080/api/"
    let network: NetworkOperation = NetworkOperation()
    
    func getVenues(location: CLLocation, completion: (Venues? -> Void)) {
        let lat: Double = location.coordinate.latitude // 60.176399230957
        let long: Double = location.coordinate.longitude // 24.8306999206543
        
        network.downloadJSONFromURL("\(apiBaseURL)venues/\(lat),\(long)") { response in
            var venues: Venues?
            
            if let json = response {
                venues = Venues(venuesList: json.arrayValue)
            } else {
                print("Loading venues failed")
            }
            
            completion(venues)
        }
    }
    
    func getMenu(venue: Venue, completion: (Menu? -> Void)) {
        // Get Date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        //let date = dateFormatter.stringFromDate(NSDate())
        //let url = "\(apiBaseURL)venues/\(venue.id)/\(date)"
        let url = "\(apiBaseURL)venues/\(venue.id)/menu/2016-03-21"
        
        network.downloadJSONFromURL(url) { response in
            var menu: Menu?

            if let json = response {
                menu = Menu(meals: json["meals"].arrayValue)
            } else {
                print("Loading menu failed")
            }
            
            completion(menu)
        }
    }
    
}