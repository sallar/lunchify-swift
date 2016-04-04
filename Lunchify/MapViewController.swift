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
    
    override func viewWillAppear(animated: Bool) {
        var name = "Unidentified Menu"
        
        if let venue = self.venue {
            name = "Navigation for: \(venue.name!)"
        }
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: name)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    func configureView() {
        if let venue = self.venue, let mapView = self.mapView {
            // Toolbar items
            let bbi = MKUserTrackingBarButtonItem(mapView:self.mapView)
            toolbar.items?.append(bbi)
            
            // Set address
            let labelFont = UIFont.systemFontOfSize(16.0, weight: UIFontWeightLight)
            let labelAttrDict: [String: AnyObject]? = [
                NSForegroundColorAttributeName: UIColor.blackColor(),
                NSFontAttributeName: labelFont
            ]
            addressLabel.setTitleTextAttributes(labelAttrDict, forState: .Disabled)
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
        for route in response.routes {
            mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
        }
    }
    
    @IBAction func showVenue(sender: AnyObject) {
        if let venue = self.venue {
            let region = MKCoordinateRegionMakeWithDistance(venue.location!.coordinate, 1000, 1000)
            mapView.setRegion(region, animated: true)
        }
    }

}

extension MapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        self.userLocation = userLocation
        
        if (followsUserLocation) {
            mapView.centerCoordinate = userLocation.location!.coordinate
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.blueColor()
        polylineRenderer.lineWidth = 2
        return polylineRenderer
    }
}