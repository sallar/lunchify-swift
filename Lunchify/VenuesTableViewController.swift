//
//  VenuesTableViewController.swift
//  Lunchify
//
//  Created by Sallar Kaboli on 11/22/15.
//  Copyright © 2015 Sallar Kaboli. All rights reserved.
//

import UIKit
import CoreLocation

class VenuesTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var venues: [Venue] = []
    var location: CLLocation?
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        
        // Location
        locationManager.delegate = self
        locationManager.distanceFilter = 500
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func configureView() {
        tableView.rowHeight = 64
        let image = UIImage(named: "logo")
        self.navigationItem.titleView = UIImageView(image: image)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: - Load Venues
    func loadVenues() {
        let venues = VenuesService()
        
        // Get venues
        venues.getVenues(self.location!) { retrievedVenues in
            if let venues = retrievedVenues {
                
                // Go back to main process
                dispatch_async(dispatch_get_main_queue()) {
                    self.venues = venues.allVenues
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
                
            } else {
                print("Fetch failed")
            }
        }
    }
    
    @IBAction func refreshVenues(sender: UIRefreshControl) {
        loadVenues()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VenueCell", forIndexPath: indexPath) as! VenueTableViewCell
        let venue = self.venues[indexPath.row]

        // Configure the cell...
        cell.venueTitleLabel?.text = venue.name
        cell.venueAddressLabel?.text = venue.address
        
        if let location = self.location {
            cell.venueDistanceLabel?.text = venue.distanceFromLocation(location)
        }
        
        return cell
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowVenue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let venue = venues[indexPath.row]
                let controller = (segue.destinationViewController as! MenuTableViewController)
                controller.venue = venue
            }
        } else if segue.identifier == "ShowAbout" {
            /*let controller = (segue.destinationViewController as! AboutViewController)
            controller.view.backgroundColor = UIColor.clearColor()
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
            controller.view.addSubview(blurEffectView)*/
            
            //self.modalPresentationStyle = .OverCurrentContext
        }
    }
    
    // MARK: - Location
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if self.location == nil {
            self.location = locations.first
            self.loadVenues()
        } else {
            self.location = locations.first
        }
    }


}
