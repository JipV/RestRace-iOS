//
//  RaceController.swift
//  RestRace iOS
//
//  Created by User on 09/04/15.
//  Copyright (c) 2015 User. All rights reserved.
//

import UIKit

class RaceController: UIViewController {
    
    @IBOutlet weak var naamLabel: UILabel!
    @IBOutlet weak var starttijdLabel: UILabel!
    @IBOutlet weak var eindtijdLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var race: Race?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let startTime = dateFormatter.dateFromString(self.race!.startTime!)
        println("Start: \(startTime)")
        
        self.naamLabel.text = self.race!.name!
        self.starttijdLabel.text = "Start time\n\(startTime)"
        
        if (self.race!.endTime != nil) {
            let endTime = dateFormatter.dateFromString(self.race!.endTime!)
            self.eindtijdLabel.text = "End time\n\(endTime)"
        }
        else {
            self.eindtijdLabel.text = ""
        }
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.race!.waypoints.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var waypointCell: WaypointCell = self.tableView.dequeueReusableCellWithIdentifier("waypointCell") as! WaypointCell
        waypointCell.naam.text = self.race!.waypoints[indexPath.row].name
        waypointCell.aantalDeelnemers.text = String("\(self.race!.participants.count) deelnemers")
        return waypointCell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "toWaypoint") {
            let indexPath = self.tableView.indexPathForSelectedRow()
            let waypoint: Waypoint = race!.waypoints[indexPath!.row]
            let waypointController = segue.destinationViewController as! WaypointController
            waypointController.waypoint = waypoint
            waypointController.hidesBottomBarWhenPushed = true;
        }
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
