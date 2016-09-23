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
    
    let lang = (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode)! as! String
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
            separated = separated.reversed()
            langs = langs.reversed()
        }
    }
    
    func isEmpty() -> Bool {
        return separated[0].count == 0 && separated[0].count == 0
    }
    
    func getLanguageForIndex(_ index: Int) -> String {
        return langs[index]
    }
    
    func getMealsForIndex(_ index: Int) -> [JSON] {
        return separated[index]
    }
    
    func getSetsCount() -> Int {
        return separated.count
    }
    
}
