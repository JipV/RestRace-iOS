//
//  RaceCell.swift
//  RestRace iOS
//
//  Created by User on 04/04/15.
//  Copyright (c) 2015 User. All rights reserved.
//

import UIKit

class RaceCell: UITableViewCell {

    @IBOutlet weak var naam: UILabel!
    @IBOutlet weak var aantalWaypoints: UILabel!
    @IBOutlet weak var vinkje: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
