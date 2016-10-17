//
//  MenuTableViewCell.swift
//  Lunchify
//
//  Created by Sallar Kaboli on 3/30/16.
//  Copyright © 2016 Sallar Kaboli. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var mealTitle: UILabel?
    @IBOutlet weak var mealFlags: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
