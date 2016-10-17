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
    let HUD = JGProgressHUD(style: .dark)
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        var name = "Unidentified Menu"
        
        if let venue = self.venue {
            name = "Menu for: \(venue.name!)"
        }
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: name)
        
        let build = GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject]
        tracker?.send(build)
    }
    
    func configureView() {
        tableView.separatorColor = UIColor("#F0F0F0")
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Progress
        HUD?.textLabel.text = NSLocalizedString("LOADING", comment: "Loading...")
        HUD?.show(in: self.navigationController?.view)
        
        // Info
        if let venue = self.venue, let location = self.location {
            self.venueNameLabel?.text = venue.name
            self.venueAddressLabel?.text = venue.address
            self.distanceLabel?.text = venue.distanceFromLocation(location)
            self.dateLabel?.text = date!.capitalized
        }
        
        // Navigation
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    }
    
    func loadMenu() {
        if let venue = self.venue {
            // Get venues
            service.getMenu(venue) { retrievedMenu in
                DispatchQueue.main.async {
                    self.HUD?.dismiss()
                    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMap" {
            let controller = (segue.destination as! MapViewController)
            controller.venue = venue
        }
    }
    
    @IBAction func goToNavigation(_ sender: AnyObject) {
        performSegue(withIdentifier: "ShowMap", sender: sender)
    }
}

extension MenuViewController:
    UITableViewDelegate,
    UITableViewDataSource,
    DZNEmptyDataSetSource,
    DZNEmptyDataSetDelegate {
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let menu = self.menu , !menu.isEmpty() {
            return menu.getSetsCount()
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let menu = self.menu , !menu.isEmpty() {
            return menu.getLanguageForIndex(section)
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let menu = self.menu , !menu.isEmpty() {
            return menu.getMealsForIndex(section).count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell", for: indexPath) as! MenuTableViewCell
        
        // Configure the cell...
        if let menu = self.menu , !menu.isEmpty() {
            let meals = menu.getMealsForIndex(indexPath.section)
            let meal = meals[indexPath.row]
            let flags:[String] = meal["flags"].arrayValue.map { $0.string!.uppercased() }
            
            cell.mealTitle?.text = meal["title"].stringValue
            if flags.count > 0 {
                cell.mealFlags?.isHidden = false
                cell.mealFlags?.text = flags.joined(separator: ", ")
            } else {
                cell.mealFlags?.isHidden = true
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.white
        header.textLabel?.textColor = UIColor.gray
        header.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    // MARK: - Empty View
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "no-menu")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: NSLocalizedString("NO_MENU", comment: "No menu"))
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: NSLocalizedString("NO_MENU_DESC", comment: "Not open maybe"))
    }
    
    func emptyDataSetWillAppear(_ scrollView: UIScrollView!) {
        self.tableView.tableHeaderView?.isHidden = true
    }
    
    func emptyDataSetWillDisappear(_ scrollView: UIScrollView!) {
        self.tableView.tableHeaderView?.isHidden = false
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return self.shouldEmptyStateBeShowed
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white
    }
    
}
