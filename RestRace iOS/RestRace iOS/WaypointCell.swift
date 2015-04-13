//
//  WaypointCell.swift
//  RestRace iOS
//
//  Created by User on 09/04/15.
//  Copyright (c) 2015 User. All rights reserved.
//

import UIKit

class WaypointCell: UITableViewCell {
    
    @IBOutlet weak var naam: UILabel!
    @IBOutlet weak var vinkje: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
