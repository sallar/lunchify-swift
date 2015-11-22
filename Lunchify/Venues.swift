//
//  Venues.swift
//  Lunchify
//
//  Created by Sallar Kaboli on 11/22/15.
//  Copyright © 2015 Sallar Kaboli. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Venues {
    
    var allVenues: [Venue] = []
    
    init(venuesList: [JSON]) {
        for venueItem in venuesList {
            let venue = Venue(venue: venueItem)
            allVenues.append(venue)
        }
    }
}