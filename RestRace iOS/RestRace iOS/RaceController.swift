//
//  RaceController.swift
//  RestRace iOS
//
//  Created by Jip Verhoeven on 09/04/15.
//  Copyright (c) 2015 Jip Verhoeven. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class RaceController: UIViewController {
    
    var locManager = CLLocationManager()
    
    @IBOutlet weak var naamLabel: UILabel!
    @IBOutlet weak var starttijdLabel: UILabel!
    @IBOutlet weak var eindtijdLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var race: Race?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.naamLabel.text = self.race!.name!
        
        let dateFormatter = NSDateFormatter()
        
        // Toont de start tijd in het goede formaat
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'.000Z'"
        let startTimeAsDate = dateFormatter.dateFromString(self.race!.startTime!)
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let startTimeAsString = dateFormatter.stringFromDate(startTimeAsDate!)
        
        self.starttijdLabel.text = "Start time\n\(startTimeAsString)"
        
        // Toont eventueel de eindtijd in het goede formaat
        if (self.race!.endTime != nil) {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'.000Z'"
            let endTimeAsDate = dateFormatter.dateFromString(self.race!.endTime!)
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
            let endTimeAsString = dateFormatter.stringFromDate(endTimeAsDate!)
            self.eindtijdLabel.text = "End time\n\(endTimeAsString)"
        }
        else {
            self.eindtijdLabel.text = ""
        }
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Zorgt ervoor dat lege rijen niet worden getoond
        var backgroundView = UIView(frame: CGRectZero)
        self.tableView.tableFooterView = backgroundView
        self.tableView.backgroundColor = UIColor.clearColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.race!.waypoints.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var waypointCell: WaypointCell = self.tableView.dequeueReusableCellWithIdentifier("waypointCell") as! WaypointCell
        waypointCell.naam.text = self.race!.waypoints[indexPath.row].name
        
        // Toont per waypoint de status
        let visitedWaypoints = MyVariables.defaults.arrayForKey("visitedWaypoints") as! [String]
        if (find(visitedWaypoints, self.race!.waypoints[indexPath.row].id!) == nil) {
            waypointCell.vinkje.hidden = true
        }
        
        return waypointCell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "toWaypoint") {
            // Toont info van de waypoint
            let indexPath = self.tableView.indexPathForSelectedRow()
            let waypoint: Waypoint = race!.waypoints[indexPath!.row]
            let waypointController = segue.destinationViewController as! WaypointController
            waypointController.waypoint = waypoint
            waypointController.hidesBottomBarWhenPushed = true;
        }
    }

    @IBAction func inchecken(sender: UIButton) {
        // Vraagt toestemming voor toegang tot de locatie
        locManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse) {
            
            // Bepaalt de locatie
            locManager.startUpdatingLocation()
            
            if (locManager.location != nil) {
                let currentLocation = locManager.location
            
                let raceID: String = self.race!.id!
                let lat = currentLocation.coordinate.latitude
                let long = currentLocation.coordinate.longitude
                let authKey: String? = MyVariables.defaults.stringForKey("authKey")
            
                let url = NSURL(string: "\(MyVariables.restRace)races/\(raceID)/location/\(lat)/\(long)?apikey=\(authKey!)")!
                var request = NSMutableURLRequest(URL: url)
                request.addValue("application/json", forHTTPHeaderField: "Accept")
            
                request.HTTPMethod = "PUT"
            
                // Request
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                    (response, data, error) in
                
                    // Parse JSON
                    var parseError: NSError?
                    let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data,
                        options: NSJSONReadingOptions.AllowFragments,
                        error:&parseError)
                    
                    self.response(parsedObject as! NSDictionary)
                }
            }
            else {
                // Toont een melding als er geen locatie is gevonden
                var refreshAlert = UIAlertController(title: "Mislukt", message: "Er is geen locatie gevonden.", preferredStyle: UIAlertControllerStyle.Alert)
                refreshAlert.addAction(UIAlertAction(title: "Sluiten", style: UIAlertActionStyle.Cancel) { UIAlertAction in })
                presentViewController(refreshAlert, animated: true, completion: nil)
            }
        }
        else if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied) {
            // Toont de melding als de app geen toegang heeft tot de locatie
            let alert = UIAlertController(title: "Geen toegang tot locatie", message: "Om in te kunnen checken heeft de app toegang nodig tot de locatie. U kunt setttings openen om de toegang te wijzigen.", preferredStyle: .Alert)
            
            let cancelActie = UIAlertAction(title: "Sluiten", style: .Cancel, handler: nil)
            alert.addAction(cancelActie)
            
            let openActie = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    // Opent settings
                    UIApplication.sharedApplication().openURL(url)
                }
                
            }
            alert.addAction(openActie)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func response(result: NSDictionary) {
        if (result["checkedIn"] as? Bool == true) {
            
            // Verzamelt de visited waypoints van de gebruiker en slaat deze op
            var visitedWaypointsArray: [String] = []
            for visitedWaypoint in result["locations"] as! NSArray {
                let waypoint = visitedWaypoint as! NSDictionary
                visitedWaypointsArray.append(visitedWaypoint["location"] as! String)
            }
            MyVariables.defaults.setObject(visitedWaypointsArray, forKey: "visitedWaypoints")
            
            // Geeft een melding als de gebruiker is ingecheckt
            var refreshAlert = UIAlertController(title: "Ingecheckt", message: "U bent dicht genoeg bij een waypoint en bent ingecheckt.", preferredStyle: UIAlertControllerStyle.Alert)
            refreshAlert.addAction(UIAlertAction(title: "Sluiten", style: UIAlertActionStyle.Cancel) { UIAlertAction in })
            presentViewController(refreshAlert, animated: true, completion: nil)
        }
        else {
            // Geeft een melding als de gebruiker niet is ingecheckt
            var refreshAlert = UIAlertController(title: "Niet ingecheckt", message: "U bent niet dicht genoeg bij een waypoint en bent daarom niet ingecheckt.", preferredStyle: UIAlertControllerStyle.Alert)
            refreshAlert.addAction(UIAlertAction(title: "Sluiten", style: UIAlertActionStyle.Cancel) { UIAlertAction in })
            presentViewController(refreshAlert, animated: true, completion: nil)
        }
    }

}
