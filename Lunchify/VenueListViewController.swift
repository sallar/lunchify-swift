//
//  VenueListViewController.swift
//  Lunchify
//
//  Created by Sallar Kaboli on 9/3/16.
//  Copyright © 2016 Sallar Kaboli. All rights reserved.
//

import UIKit
import CoreLocation
import JGProgressHUD
import UIColor_Hex_Swift

class VenueListViewController: UIViewController, CLLocationManagerDelegate {
    
    var shouldEmptyStateBeShowed: Bool = false
    var venues: [Venue] = []
    let venuesService = VenuesService()
    var location: CLLocation? {
        didSet {
            if oldValue == nil {
                loadVenues()
            }
        }
    }
    let locationManager = CLLocationManager()
    let HUD = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        
        // Location
        locationManager.delegate = self
        locationManager.distanceFilter = 100
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Venues List")
        
        let build = GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject]
        tracker?.send(build)
    }
    
    func configureView() {
        // Navigation
        let image = UIImage(named: "logo")
        self.navigationItem.titleView = UIImageView(image: image)
        //self.navigationController?.navigationBar.subviews[0].subviews[1].isHidden = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    }
    
    func endRefreshing() {
        self.HUD?.dismiss()
    }
    
    func venuesDidLoad(_ venues: Venues) {
    }
    
    // MARK: - Load Venues
    
    func loadVenues() {
        // Get venues
        if let location = self.location {
            venuesService.getVenues(location) { retrievedVenues in
                if let venues = retrievedVenues {
                    
                    // Go back to main process
                    DispatchQueue.main.async {
                        self.venues = venues.allVenues
                        self.venuesDidLoad(venues)
                        self.endRefreshing()
                    }
                    
                } else {
                    print("Fetch failed")
                }
            }
        } else {
            self.endRefreshing()
        }
    }
    
    // MARK: - Location
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .restricted || status == .denied {
            self.shouldEmptyStateBeShowed = true
            self.endRefreshing()
        }
    }
    
}
