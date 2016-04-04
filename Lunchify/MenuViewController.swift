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
import DZNEmptyDataSet
import GoogleAnalytics

class MenuViewController: UIViewController {

    var location: CLLocation?
    var date: String?
    var venue: Venue? {
        didSet {
            loadMenu()
        }
    }
    
    var menu: Menu?
    let service = VenuesService()
    var shouldEmptyStateBeShowed: Bool = false
    let HUD = JGProgressHUD(style: .Dark)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var venueAddressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        
        // Delegates
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        var name = "Unidentified Menu"
        
        if let venue = self.venue {
            name = "Menu for: \(venue.name!)"
        }
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: name)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    func configureView() {
        tableView.separatorColor = UIColor(rgba: "#F0F0F0")
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Progress
        HUD.textLabel.text = NSLocalizedString("LOADING", comment: "Loading...")
        HUD.showInView(self.navigationController?.view)
        
        // Info
        if let venue = self.venue, let location = self.location {
            self.venueNameLabel?.text = venue.name
            self.venueAddressLabel?.text = venue.address
            self.distanceLabel?.text = venue.distanceFromLocation(location)
            self.dateLabel?.text = date!.capitalizedString
        }
        
        // Navigation
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
    }
    
    func loadMenu() {
        if let venue = self.venue {
            // Get venues
            service.getMenu(venue) { retrievedMenu in
                dispatch_async(dispatch_get_main_queue()) {
                    self.HUD.dismiss()
                    
                    if let menu = retrievedMenu {
                        self.menu = menu
                        if menu.isEmpty() {
                            self.shouldEmptyStateBeShowed = true
                        }
                        self.tableView.reloadData()
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
    
    @IBAction func goToNavigation(sender: AnyObject) {
        performSegueWithIdentifier("ShowMap", sender: sender)
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let menu = self.menu where !menu.isEmpty() {
            return menu.getSetsCount()
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let menu = self.menu where !menu.isEmpty() {
            return menu.getLanguageForIndex(section)
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let menu = self.menu where !menu.isEmpty() {
            return menu.getMealsForIndex(section).count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MealCell", forIndexPath: indexPath) as! MenuTableViewCell
        
        // Configure the cell...
        if let menu = self.menu where !menu.isEmpty() {
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
    
    // MARK: - Empty View
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "no-menu")
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: NSLocalizedString("NO_MENU", comment: "No menu"))
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: NSLocalizedString("NO_MENU_DESC", comment: "Not open maybe"))
    }
    
    func emptyDataSetWillAppear(scrollView: UIScrollView!) {
        self.tableView.tableHeaderView?.hidden = true
    }
    
    func emptyDataSetWillDisappear(scrollView: UIScrollView!) {
        self.tableView.tableHeaderView?.hidden = false
    }
    
    func emptyDataSetShouldDisplay(scrollView: UIScrollView!) -> Bool {
        return self.shouldEmptyStateBeShowed
    }
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor.whiteColor()
    }
    
}
