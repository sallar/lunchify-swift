//
//  VenuesTableViewController.swift
//  Lunchify
//
//  Created by Sallar Kaboli on 11/22/15.
//  Copyright © 2015 Sallar Kaboli. All rights reserved.
//

import UIKit
import CoreLocation
import JGProgressHUD
import UIColor_Hex_Swift
import DZNEmptyDataSet

class VenuesTableViewController: VenueListViewController {
    
    var filteredVenues: [Venue] = []
    var resultSearchController: UISearchController?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refreshControl: UIRefreshControl!

    override func configureView() {
        tableView.estimatedRowHeight = 64.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorColor = UIColor(rgba: "#F0F0F0")
        
        // Progress
        HUD.textLabel.text = NSLocalizedString("LOADING", comment: "Loading...")
        HUD.showInView(self.navigationController?.view)
        
        // Navigation
        let image = UIImage(named: "logo")
        self.navigationItem.titleView = UIImageView(image: image)
        self.navigationController?.navigationBar.subviews[0].subviews[1].hidden = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        // Search bar
        definesPresentationContext = true
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.searchBarStyle = .Minimal
            controller.searchBar.tintColor = UIColor(rgba: "#C2185B")
            controller.searchBar.sizeToFit()
            
            self.tableView.tableHeaderView = controller.searchBar
            return controller
        })()
        
        // Empty State
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
    
    override func venuesDidLoad(venues: Venues) {
        self.filteredVenues = self.venues
        self.shouldEmptyStateBeShowed = (venues.allVenues.count == 0)
    }
    
    override func endRefreshing() {
        super.endRefreshing()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    @IBAction func refreshVenues(sender: UIRefreshControl) {
        loadVenues()
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowVenue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let venue = filteredVenues[indexPath.row]
                let controller = (segue.destinationViewController as! MenuViewController)
                controller.venue = venue
                controller.location = self.location
                controller.date = venuesService.getMenuDate("EEEE")
            }
        }
    }
}

extension VenuesTableViewController: UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UISearchResultsUpdating {
    
    // MARK: - Search
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filteredVenues = searchText.isEmpty ? venues : venues.filter({(venue: Venue) -> Bool in
                return venue.name!.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
            })
            
            tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredVenues.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VenueCell", forIndexPath: indexPath) as! VenueTableViewCell
        let venue = self.filteredVenues[indexPath.row]
        
        // Configure the cell...
        cell.venueTitleLabel?.text = venue.name
        cell.venueAddressLabel?.text = venue.address
        
        if let location = self.location {
            cell.venueDistanceLabel?.text = venue.distanceFromLocation(location)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Empty View
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "no-venue")
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: NSLocalizedString("NO_VENUES", comment: "No venues"))
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: NSLocalizedString("NO_VENUES_DESC", comment: "Will add soon"))
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        return NSAttributedString(string: NSLocalizedString("RELOAD", comment: "Reload"))
    }
    
    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        HUD.showInView(self.navigationController?.view)
        loadVenues()
    }
    
    func emptyDataSetShouldDisplay(scrollView: UIScrollView!) -> Bool {
        return self.shouldEmptyStateBeShowed
    }
    
}
