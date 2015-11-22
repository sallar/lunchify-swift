//
//  Venue.swift
//  Lunchify
//
//  Created by Sallar Kaboli on 11/22/15.
//  Copyright © 2015 Sallar Kaboli. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Venue {
    
    var name: String?
    var address: String?
    
    init(venue: JSON) {
        name = venue["name"].string
        address = venue["address"].string
    }
    
}