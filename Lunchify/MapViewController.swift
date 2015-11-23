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
    
    var pointAnnotation: MKPointAnnotation!
    var pinAnnotationView: MKPinAnnotationView!
    
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
        if let venue = self.venue, let mapView = self.mapView {
            //mapView.centerCoordinate = venue.location!.coordinate
            
            // Zoom in to venue
            let region = MKCoordinateRegionMakeWithDistance(
                venue.location!.coordinate, 2000, 2000)
            
            mapView.setRegion(region, animated: true)
            
            // Add annotation
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = venue.name
            self.pointAnnotation.coordinate = venue.location!.coordinate
            
            // Add annotation to pin annotation view
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
            
            // Find the route
            let placemark = MKPlacemark(coordinate: venue.location!.coordinate, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            let request = MKDirectionsRequest()
            request.source = MKMapItem.mapItemForCurrentLocation()
            request.destination = mapItem
            request.requestsAlternateRoutes = false
            
            let directions = MKDirections(request: request)
            
            directions.calculateDirectionsWithCompletionHandler { (response, error) -> Void in
                if error != nil {
                    print("No navigation")
                } else {
                    self.showRoute(response!)
                }
                
            }
        }
    }
    
    func showRoute(response: MKDirectionsResponse) {
        print(response.routes)
        for route in response.routes {
            print(route.polyline)
            mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

extension MapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        //mapView.centerCoordinate = userLocation.location!.coordinate
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.blueColor()
        polylineRenderer.lineWidth = 2
        return polylineRenderer
    }
}