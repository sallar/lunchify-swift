//
//  VenuesMapViewController.swift
//  Lunchify
//
//  Created by Sallar Kaboli on 9/3/16.
//  Copyright © 2016 Sallar Kaboli. All rights reserved.
//

import UIKit
import MapKit

class VenuesMapViewController: VenueListViewController {

    @IBOutlet var mapView: MKMapView!
    
    override func venuesDidLoad(venues: Venues) {
        print(venues)
    }

}
