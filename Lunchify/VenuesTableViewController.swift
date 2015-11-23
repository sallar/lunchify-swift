//
//  VenuesTableViewController.swift
//  Lunchify
//
//  Created by Sallar Kaboli on 11/22/15.
//  Copyright © 2015 Sallar Kaboli. All rights reserved.
//

import UIKit
import CoreLocation

class VenuesTableViewController: UITableViewController {
    
    var venues: [Venue] = []
    var location: CLLocation = CLLocation(latitude: 24.8306999206543, longitude: 60.176399230957)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.loadVenues()
    }

    func configureView() {
        tableView.rowHeight = 64
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: - Load Venues
    func loadVenues() {
        let venues = VenuesService()
        
        // Get venues
        venues.getVenues { retrievedVenues in
            if let venues = retrievedVenues {
                
                // Go back to main process
                dispatch_async(dispatch_get_main_queue()) {
                    self.venues = venues.allVenues
                    self.tableView.reloadData()
                }
                
            } else {
                print("Fetch failed")
            }
        }
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
        cell.venueDistanceLabel?.text = venue.distanceFromLocation(location)
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowVenue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let venue = venues[indexPath.row]
                let controller = (segue.destinationViewController as! MenuTableViewController)
                controller.venue = venue
            }
        }
    }


}
