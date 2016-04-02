//
//  MenuTableViewController.swift
//  Lunchify
//
//  Created by Sallar Kaboli on 11/23/15.
//  Copyright © 2015 Sallar Kaboli. All rights reserved.
//

import UIKit
import JGProgressHUD
import CoreLocation

class MenuViewController: UIViewController {

    var location: CLLocation?
    var venue: Venue? {
        didSet {
            loadMenu()
        }
    }
    
    var menu: Menu?
    let service = VenuesService()
    let HUD = JGProgressHUD(style: .Dark)
    
    @IBOutlet weak var notAvailable: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var venueAddressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        
        // Delegates
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func configureView() {
        tableView.separatorColor = UIColor(rgba: "#F0F0F0")
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Hide stuff
        notAvailable.hidden = true
        
        // Progress
        HUD.textLabel.text = NSLocalizedString("LOADING", comment: "Loading...")
        HUD.showInView(self.navigationController?.view)
        
        // Info
        if let venue = self.venue, let location = self.location {
            self.venueNameLabel?.text = venue.name
            self.venueAddressLabel?.text = venue.address
            self.distanceLabel?.text = venue.distanceFromLocation(location)
        }
    }
    
    func loadMenu() {
        if let venue = self.venue {
            // Get venues
            service.getMenu(venue) { retrievedMenu in
                dispatch_async(dispatch_get_main_queue()) {
                    self.HUD.dismiss()
                    
                    if let menu = retrievedMenu {
                        self.menu = menu
                        self.tableView.reloadData()
                        
                        if menu.isEmpty() {
                            self.tableView.hidden = true
                            self.notAvailable.hidden = false
                        }
                    } else {
                        self.tableView.hidden = true
                        self.notAvailable.hidden = false
                    }
                }
            }
        }
        
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowMap" {
            let controller = (segue.destinationViewController as! MapViewController)
            controller.venue = venue
        }
    }
    
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let menu = self.menu {
            return menu.getSetsCount()
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let menu = self.menu {
            return menu.getLanguageForIndex(section)
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let menu = self.menu {
            return menu.getMealsForIndex(section).count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MealCell", forIndexPath: indexPath) as! MenuTableViewCell
        
        // Configure the cell...
        if let menu = self.menu {
            let meals = menu.getMealsForIndex(indexPath.section)
            let meal = meals[indexPath.row]
            let flags:[String] = meal["flags"].arrayValue.map { $0.string!.uppercaseString }
            
            cell.mealTitle?.text = meal["title"].stringValue
            if flags.count > 0 {
                cell.mealFlags?.hidden = false
                cell.mealFlags?.text = flags.joinWithSeparator(", ")
            } else {
                cell.mealFlags?.hidden = true
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.whiteColor()
        header.textLabel?.textColor = UIColor.grayColor()
        header.textLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
}
