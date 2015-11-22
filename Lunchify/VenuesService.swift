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
    
}