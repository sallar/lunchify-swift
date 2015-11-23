//
//  MenuTableViewController.swift
//  Lunchify
//
//  Created by Sallar Kaboli on 11/23/15.
//  Copyright © 2015 Sallar Kaboli. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {

    var venue: Venue? {
        didSet {
            configureView()
        }
    }
    
    var menu: Menu?
    let service = VenuesService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configureView() {
        
        if let venue = self.venue {
            self.title = venue.name
            
            // Get venues
            service.getMenu(venue) { retrievedMenu in
                if let menu = retrievedMenu {
                    
                    // Go back to main process
                    dispatch_async(dispatch_get_main_queue()) {
                        self.menu = menu
                        self.tableView.reloadData()
                    }
                    
                } else {
                    print("Fetch failed")
                }
            }
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let _ = self.menu {
            return 2
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Finnish"
        } else {
            return "English"
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MealCell", forIndexPath: indexPath)

        // Configure the cell...
        if let menu = self.menu {
            let meals = indexPath.section == 0 ? menu.finnish : menu.english
            let meal = meals[indexPath.row]
            cell.textLabel?.text = meal
        }

        return cell
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowMap" {
            let controller = (segue.destinationViewController as! MapViewController)
            controller.venue = venue
        }
    }
    

}
