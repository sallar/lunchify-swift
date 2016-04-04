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
    
    let apiBaseURL: String = "https://lunchify.fi/api/"
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
        let date = self.getMenuDate()
        let url = "\(apiBaseURL)venues/\(venue.id)/menu/\(date)"
        
        network.downloadJSONFromURL(url) { response in
            var menu: Menu?

            if let json = response {
                menu = Menu(meals: json["meals"].arrayValue)
            } else {
                menu = Menu(meals: [])
            }
            
            completion(menu)
        }
    }
    
    func getMenuDate(format: String = "YYYY-MM-dd") -> String {
        // Get Date
        let today = NSDate()
        
        // Formatter
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        
        // Return
        return dateFormatter.stringFromDate(today)
    }
    
}