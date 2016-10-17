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
    @IBOutlet weak var addressLabel: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    
    var pointAnnotation: MKPointAnnotation!
    var pinAnnotationView: MKPinAnnotationView!
    var followsUserLocation: Bool = false
    var userLocation: MKUserLocation?
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        var name = "Unidentified Menu"
        
        if let venue = self.venue {
            name = "Navigation for: \(venue.name!)"
        }
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: name)
        
        let build = GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject]
        tracker?.send(build)
    }
    
    func configureView() {
        if let venue = self.venue, let mapView = self.mapView {
            // Toolbar items
            let bbi = MKUserTrackingBarButtonItem(mapView:self.mapView)
            toolbar.items?.append(bbi)
            
            // Set address
            let labelFont = UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightLight)
            let labelAttrDict: [String: AnyObject]? = [
                NSForegroundColorAttributeName: UIColor.black,
                NSFontAttributeName: labelFont
            ]
            addressLabel.setTitleTextAttributes(labelAttrDict, for: .disabled)
            addressLabel.title = venue.address
            
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
            request.source = MKMapItem.forCurrentLocation()
            request.destination = mapItem
            request.requestsAlternateRoutes = false
            
            let directions = MKDirections(request: request)
            
            directions.calculate { (response, error) -> Void in
                if error != nil {
                    print("No navigation")
                } else {
                    self.showRoute(response!)
                }
            }
        }
    }
    
    func showRoute(_ response: MKDirectionsResponse) {
        for route in response.routes {
            mapView.add(route.polyline, level: MKOverlayLevel.aboveRoads)
        }
    }
    
    @IBAction func showVenue(_ sender: AnyObject) {
        if let venue = self.venue {
            let region = MKCoordinateRegionMakeWithDistance(venue.location!.coordinate, 1000, 1000)
            mapView.setRegion(region, animated: true)
        }
    }

}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        self.userLocation = userLocation
        
        if (followsUserLocation) {
            mapView.centerCoordinate = userLocation.location!.coordinate
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.blue
        polylineRenderer.lineWidth = 2
        return polylineRenderer
    }
}
