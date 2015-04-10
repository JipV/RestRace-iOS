//
//  WaypointController.swift
//  RestRace iOS
//
//  Created by Jip Verhoeven on 10/04/15.
//  Copyright (c) 2015 User. All rights reserved.
//

import UIKit

class WaypointController: UIViewController {
    
    @IBOutlet weak var naamLabel: UILabel!
    @IBOutlet weak var omschrijvingLabel: UILabel!
    
    var waypoint: Waypoint?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.naamLabel.text = self.waypoint!.name!
        self.waypoint!.description != nil ? (self.omschrijvingLabel.text = "Omschrijving:\n\(self.waypoint!.description!)") : (self.omschrijvingLabel.text = "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
