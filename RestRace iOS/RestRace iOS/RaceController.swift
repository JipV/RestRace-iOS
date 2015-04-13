//
//  RaceController.swift
//  RestRace iOS
//
//  Created by User on 09/04/15.
//  Copyright (c) 2015 User. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class RaceController: UIViewController {
    
    let restRace: String = "https://restrace2.herokuapp.com/"
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var locManager = CLLocationManager()
    
    @IBOutlet weak var naamLabel: UILabel!
    @IBOutlet weak var starttijdLabel: UILabel!
    @IBOutlet weak var eindtijdLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var race: Race?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm"
        
        /*var date = self.race!.startTime!
        date = date.substringWithRange(Range<String.Index>(start: advance(date.startIndex, 0), end: advance(date.endIndex, -5)))
        println(date)*/
        
        var startTime = dateFormatter.dateFromString(self.race!.startTime!)
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
        
        let visitedWaypoints = self.defaults.arrayForKey("visitedWaypoints") as! [String]
        if (find(visitedWaypoints, self.race!.waypoints[indexPath.row].id!) == nil) {
            waypointCell.vinkje.hidden = true
        }
        
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

    @IBAction func inchecken(sender: UIButton) {
        locManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse) {
            locManager.startUpdatingLocation()
            if (locManager.location != nil) {
                let currentLocation = locManager.location
            
                let raceID: String = self.race!.id!
                let lat = currentLocation.coordinate.latitude
                let long = currentLocation.coordinate.longitude
                let authKey: String? = defaults.stringForKey("authKey")
            
                let url = NSURL(string: "\(restRace)races/\(raceID)/location/\(lat)/\(long)?apikey=\(authKey!)")!
                var request = NSMutableURLRequest(URL: url)
                request.addValue("application/json", forHTTPHeaderField: "Accept")
            
                request.HTTPMethod = "PUT"
            
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                    (response, data, error) in
                
                    var parseError: NSError?
                    let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data,
                        options: NSJSONReadingOptions.AllowFragments,
                        error:&parseError)
                    
                    self.response(parsedObject as! NSDictionary)
                }
                
            println("lat = \(currentLocation.coordinate.latitude)")
            println("long = \(currentLocation.coordinate.longitude)")
            }
            else {
                var refreshAlert = UIAlertController(title: "Mislukt", message: "Er is geen locatie gevonden.", preferredStyle: UIAlertControllerStyle.Alert)
                refreshAlert.addAction(UIAlertAction(title: "Sluiten", style: UIAlertActionStyle.Cancel) { UIAlertAction in })
                presentViewController(refreshAlert, animated: true, completion: nil)
            }
        }
        else if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied) {
            
            let alert = UIAlertController(title: "Geen toegang tot locatie", message: "Om in te kunnen checken heeft de app toegang nodig tot de locatie. U kunt setttings openen om de toegang te wijzigen.", preferredStyle: .Alert)
            
            let cancelActie = UIAlertAction(title: "Sluiten", style: .Cancel, handler: nil)
            alert.addAction(cancelActie)
            
            let openActie = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
                
            }
            alert.addAction(openActie)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func response(result: NSDictionary) {
        if (result["checkedIn"] as? Bool == true) {
            
            var visitedWaypointsArray: [String] = []
            for visitedWaypoint in result["locations"] as! NSArray {
                let waypoint = visitedWaypoint as! NSDictionary
                visitedWaypointsArray.append(visitedWaypoint["location"] as! String)
            }
            defaults.setObject(visitedWaypointsArray, forKey: "visitedWaypoints")
            
            var refreshAlert = UIAlertController(title: "Ingecheckt", message: "U bent dicht genoeg bij een waypoint en bent ingecheckt.", preferredStyle: UIAlertControllerStyle.Alert)
            refreshAlert.addAction(UIAlertAction(title: "Sluiten", style: UIAlertActionStyle.Cancel) { UIAlertAction in })
            presentViewController(refreshAlert, animated: true, completion: nil)
        }
        else {
            var refreshAlert = UIAlertController(title: "Niet ingecheckt", message: "U bent niet dicht genoeg bij een waypoint en bent daarom niet ingecheckt.", preferredStyle: UIAlertControllerStyle.Alert)
            refreshAlert.addAction(UIAlertAction(title: "Sluiten", style: UIAlertActionStyle.Cancel) { UIAlertAction in })
            presentViewController(refreshAlert, animated: true, completion: nil)
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
