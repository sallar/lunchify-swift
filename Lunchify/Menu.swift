//
//  Menu.swift
//  Lunchify
//
//  Created by Sallar Kaboli on 11/23/15.
//  Copyright © 2015 Sallar Kaboli. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Menu {
    
    var finnish: [String] = []
    var english: [String] = []
    
    init(meals: [JSON]) {
        
        for meal in meals {
            if meal["english"].boolValue {
                english.append(meal["name"].stringValue)
            } else {
                finnish.append(meal["name"].stringValue)
            }
        }
        
    }
    
}