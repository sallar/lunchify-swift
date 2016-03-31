//
//  MenuTableViewController.swift
//  Lunchify
//
//  Created by Sallar Kaboli on 11/23/15.
//  Copyright © 2015 Sallar Kaboli. All rights reserved.
//

import UIKit
import JGProgressHUD

class MenuViewController: UIViewController {

    var venue: Venue? {
        didSet {
            configureView()
        }
    }
    
    var menu: Menu?
    let service = VenuesService()
    let HUD = JGProgressHUD(style: .Dark)
    
    @IBOutlet weak var notAvailable: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegates
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Hide stuff
        notAvailable.hidden = true
        
        // Progress
        HUD.textLabel.text = "Loading..."
        HUD.showInView(self.navigationController?.view)
    }
    
    func configureView() {
        
        if let venue = self.venue {
            self.title = venue.name
            
            // Get venues
            service.getMenu(venue) { retrievedMenu in
                dispatch_async(dispatch_get_main_queue()) {
                    self.HUD.dismiss()
                    
                    if let menu = retrievedMenu {
                        self.menu = menu
                        self.tableView.reloadData()
                        
                        if menu.english.count == 0 && menu.finnish.count == 0 {
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
            return (menu.finnish.count > 0 && menu.english.count > 0) ? 2 : 1
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let menu = self.menu {
            if menu.finnish.count > 0 || menu.english.count > 0 {
                if section == 0 {
                    return menu.finnish.count > 0 ? "Finnish" : "English"
                } else {
                    return "English"
                }
            }
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let menu = self.menu {
            switch section {
            case 0:
                return menu.finnish.count
            case 1:
                return menu.english.count
            default:
                return 0
            }
        } else {
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MealCell", forIndexPath: indexPath) as! MenuTableViewCell
        
        // Configure the cell...
        if let menu = self.menu {
            let meals = indexPath.section == 0 ? menu.finnish : menu.english
            let meal = meals[indexPath.row]
            let flags:[String] = meal["flags"].arrayValue.map { $0.string!.uppercaseString }
            
            cell.mealTitle?.text = meal["title"].stringValue
            cell.mealFlags?.text = flags.joinWithSeparator(", ")
        }
        
        return cell
    }
    
}
