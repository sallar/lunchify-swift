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
    
    var pointAnnotation: MKPointAnnotation!
    var pinAnnotationView: MKPinAnnotationView!
    var hasBeenCentered: Bool = false
    var userLocation: MKUserLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    override func venuesDidLoad(venues: Venues) {
        print(venues)
    }

}

extension VenuesMapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        self.userLocation = userLocation
        
        if (!hasBeenCentered) {
            hasBeenCentered = true
            let latitude = userLocation.location!.coordinate.latitude
            let longitude = userLocation.location!.coordinate.longitude
            let latDelta: CLLocationDegrees = 0.05
            let lonDelta: CLLocationDegrees = 0.05
            let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
            let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            mapView.setRegion(region, animated: true)
        }
    }
    
}