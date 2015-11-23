//
//  VenuesService.swift
//  Lunchify
//
//  Created by Sallar Kaboli on 11/22/15.
//  Copyright © 2015 Sallar Kaboli. All rights reserved.
//

import Foundation

struct VenuesService {
    
    let apiBaseURL: String = "http://lunchify/api/"
    let network: NetworkOperation = NetworkOperation()
    
    func getVenues(completion: (Venues? -> Void)) {
        network.downloadJSONFromURL("\(apiBaseURL)venues/60.176399230957,24.8306999206543") { response in
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
        let url = "\(apiBaseURL)venues/\(venue.id)/2015-11-23"
        
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