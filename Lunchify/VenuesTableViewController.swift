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
        super.configureView()
        tableView.estimatedRowHeight = 64.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorColor = UIColor("#F0F0F0")
        
        // Progress
        HUD?.textLabel.text = NSLocalizedString("LOADING", comment: "Loading...")
        HUD?.show(in: self.navigationController?.view)
        
        // Search bar
        definesPresentationContext = true
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.searchBarStyle = .minimal
            controller.searchBar.tintColor = UIColor("#C2185B")
            controller.searchBar.sizeToFit()
            
            self.tableView.tableHeaderView = controller.searchBar
            return controller
        })()
        
        // Empty State
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
    
    override func venuesDidLoad(_ venues: Venues) {
        self.filteredVenues = self.venues
        self.shouldEmptyStateBeShowed = (venues.allVenues.count == 0)
    }
    
    override func endRefreshing() {
        super.endRefreshing()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    @IBAction func refreshVenues(_ sender: UIRefreshControl) {
        loadVenues()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowVenue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let venue = filteredVenues[(indexPath as NSIndexPath).row]
                let controller = (segue.destination as! MenuViewController)
                controller.venue = venue
                controller.location = self.location
                controller.date = venuesService.getMenuDate("EEEE")
            }
        }
    }
}

extension VenuesTableViewController:
    UITableViewDelegate,
    UITableViewDataSource,
    DZNEmptyDataSetSource,
    DZNEmptyDataSetDelegate,
    UISearchResultsUpdating {
    
    // MARK: - Search
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filteredVenues = searchText.isEmpty ? venues : venues.filter({(venue: Venue) -> Bool in
                return venue.name!.range(of: searchText, options: .caseInsensitive) != nil
            })
            
            tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredVenues.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VenueCell", for: indexPath) as! VenueTableViewCell
        let venue = self.filteredVenues[(indexPath as NSIndexPath).row]
        
        // Configure the cell...
        cell.venueTitleLabel?.text = venue.name
        cell.venueAddressLabel?.text = venue.address
        
        if let location = self.location {
            cell.venueDistanceLabel?.text = venue.distanceFromLocation(location)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Empty View
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "no-venue")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: NSLocalizedString("NO_VENUES", comment: "No venues"))
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: NSLocalizedString("NO_VENUES_DESC", comment: "Will add soon"))
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        return NSAttributedString(string: NSLocalizedString("RELOAD", comment: "Reload"))
    }
    
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        HUD?.show(in: self.navigationController?.view)
        loadVenues()
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return self.shouldEmptyStateBeShowed
    }
    
}
