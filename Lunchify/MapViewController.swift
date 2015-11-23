//
//  MapViewController.swift
//  Lunchify
//
//  Created by Sallar Kaboli on 11/23/15.
//  Copyright © 2015 Sallar Kaboli. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var venue: Venue? {
        didSet {
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.showsUserLocation = true
        configureView()
    }
    
    func configureView() {
        
    }
    

}

extension MapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        //mapView.centerCoordinate = userLocation.location!.coordinate
    }
}