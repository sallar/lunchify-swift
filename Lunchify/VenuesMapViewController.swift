//
//  VenuesMapViewController.swift
//  Lunchify
//
//  Created by Sallar Kaboli on 9/3/16.
//  Copyright © 2016 Sallar Kaboli. All rights reserved.
//

import UIKit
import MapKit
import UIColor_Hex_Swift

class VenuesMapViewController: VenueListViewController {

    @IBOutlet var mapView: MKMapView!
    
    var pointAnnotation: MKPointAnnotation!
    var pinAnnotationView: MKPinAnnotationView!
    var hasBeenCentered: Bool = false
    var annotationsAdded: Bool = false
    var userLocation: MKUserLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    override func configureView() {
        super.configureView()
    }
    
    override func venuesDidLoad(_ venues: Venues) {
        addAnnotations()
    }
    
    func addAnnotations() {
        if self.venues.count > 0 && !annotationsAdded && hasBeenCentered {
            annotationsAdded = true
            for (index, venue) in self.venues.enumerated() {
                let annotation = Annotation()
                annotation.coordinate = venue.location!.coordinate
                annotation.title = venue.name
                annotation.subtitle = venue.address
                annotation.index = index
                mapView.addAnnotation(annotation)
            }
        }
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowVenue" {
            let venue = self.venues[(sender as! MKAnnotationView).tag]
            let controller = (segue.destination as! MenuViewController)
            controller.venue = venue
            controller.location = self.location
            controller.date = venuesService.getMenuDate("EEEE")
        }
    }
}

extension VenuesMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        self.userLocation = userLocation
        
        if (!hasBeenCentered) {
            hasBeenCentered = true
            let region = MKCoordinateRegionMakeWithDistance(userLocation.location!.coordinate, 1000, 1000)
            mapView.setRegion(region, animated: false)
            self.addAnnotations()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKPointAnnotation {
            let themeColor = UIColor("#C2185B")
            
            let detailButton = UIButton(type: .detailDisclosure)
            detailButton.tintColor = themeColor
            
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "venuePin")
            pinAnnotationView.pinTintColor = themeColor
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.animatesDrop = true
            pinAnnotationView.rightCalloutAccessoryView = detailButton
            pinAnnotationView.tag = (annotation as! Annotation).index
            
            return pinAnnotationView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "ShowVenue", sender: view)
    }
    
}
