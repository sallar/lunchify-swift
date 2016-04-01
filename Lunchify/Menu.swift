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
    
    let lang = NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode)! as! String
    var separated: [[JSON]] = [[], []]
    var langs: [String] = [
        NSLocalizedString("FINNISH", comment: "Finnish"),
        NSLocalizedString("ENGLISH", comment: "English"),
        ]
    
    init(meals: [JSON]) {
        for meal in meals {
            if meal["lang"] == "fin" {
                separated[0].append(meal)
            } else {
                separated[1].append(meal)
            }
        }
        
        if lang == "en" {
            separated = separated.reverse()
            langs = langs.reverse()
        }
    }
    
    func isEmpty() -> Bool {
        return separated[0].count == 0 && separated[0].count == 0
    }
    
    func getLanguageForIndex(index: Int) -> String {
        return langs[index]
    }
    
    func getMealsForIndex(index: Int) -> [JSON] {
        return separated[index]
    }
    
    func getSetsCount() -> Int {
        return separated.count
    }
    
}