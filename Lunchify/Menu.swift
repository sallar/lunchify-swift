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
    
    var finnish: [JSON] = []
    var english: [JSON] = []
    
    init(meals: [JSON]) {
        
        for meal in meals {
            if meal["lang"] == "eng" {
                english.append(meal)
            } else {
                finnish.append(meal)
            }
        }
        
    }
    
}