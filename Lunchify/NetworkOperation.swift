//
//  NetworkOperation.swift
//  Lunchify
//
//  Created by Sallar Kaboli on 11/22/15.
//  Copyright © 2015 Sallar Kaboli. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class NetworkOperation {
    
    typealias JSONDictionaryCompletion = (JSON?) -> Void
    
    func downloadJSONFromURL(url: String, completion: JSONDictionaryCompletion) {
        // Do a get request
        Alamofire.request(.GET, url).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    completion(json)
                }
            case .Failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
}