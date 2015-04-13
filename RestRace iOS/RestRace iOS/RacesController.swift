//
//  RacesController.swift
//  RestRace iOS
//
//  Created by User on 03/04/15.
//  Copyright (c) 2015 User. All rights reserved.
//

import UIKit

class RacesController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let restRace: String = "https://restrace2.herokuapp.com/"
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var racesData: [Race] = []
    
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let authKey: String? = defaults.stringForKey("authKey")
        if (authKey == nil) {
            self.performSegueWithIdentifier("toLogin", sender: self)
        }
        
        activityIndicator.frame = CGRectMake(100, 100, 100, 100);
        self.view.addSubview(activityIndicator)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        var backgroundView = UIView(frame: CGRectZero)
        self.tableView.tableFooterView = backgroundView
        self.tableView.backgroundColor = UIColor.clearColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.racesData = []
        refreshTableView()
        getRacesData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func uitloggen(sender: UIButton) {
        self.racesData = []
        refreshTableView()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(nil, forKey: "id")
        defaults.setObject(nil, forKey: "authKey")
        defaults.setObject(nil, forKey: "nickname")
        defaults.setObject(nil, forKey: "visitedWaypoints")
        
        self.performSegueWithIdentifier("toLogin", sender: self)
    }
    
    func getRacesData() {
        let authKey: String? = defaults.stringForKey("authKey")
        if (authKey != nil) {
            activityIndicator.startAnimating()
            
            let url = NSURL(string: "\(self.restRace)races?apikey=\(authKey!)&type=participant&pageSize=100")!
            var request = NSMutableURLRequest(URL: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                (response, data, error) in
            
                var parseError: NSError?
                let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data,
                    options: NSJSONReadingOptions.AllowFragments,
                    error:&parseError)
            
                self.getRacesDataFromJSON(parsedObject as! NSArray)
            }
        }
    }
    
    func getRacesDataFromJSON(races: NSArray) {
        for race in races {
            
            var ownersArray: [String] = []
            for owner in race["owners"] as! NSArray {
                ownersArray.append(owner["_id"] as! NSString as String)
            }
                
            var participantsArray: [String] = []
            for participant in race["participants"] as! NSArray {
                participantsArray.append(participant["_id"] as! NSString as String)
            }
                
            var waypointsArray: [Waypoint] = []
            for waypoint in race["locations"] as! NSArray {
                let location = waypoint["location"] as! NSDictionary
                let newWaypoint = Waypoint(
                    id: waypoint["_id"] as! String,
                    name: location["name"] as! String,
                    description: location["description"] as? String,
                    lat: location["lat"] as! Double,
                    long: location["long"] as! Double,
                    distance: location["distance"] as! Int
                )
                waypointsArray.append(newWaypoint)
            }
            
            let newRace = Race(
                id: race["_id"] as! String,
                name: race["name"] as! String,
                isPrivate: race["private"] as! Bool,
                startTime: race["startTime"] as! String,
                endTime: race["endTime"] as? String,
                owners: ownersArray,
                participants: participantsArray,
                waypoints: waypointsArray
            )
            self.racesData.append(newRace)
        }
        refreshTableView()
        activityIndicator.stopAnimating()
    }
    
    func tableView(tableView: UITableView, commitEditingStyle  editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath:   NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            let alert = UIAlertController(title: "Race verwijderen", message: "Weet u zeker dat u de race wilt verwijderen? U bent dan geen deelnemer meer van de race.", preferredStyle: .Alert)
            
            let neeActie = UIAlertAction(title: "Nee", style: .Cancel, handler: nil)
            alert.addAction(neeActie)
            
            let jaActie = UIAlertAction(title: "Ja", style: .Default) { (action) in
                
                let raceID: String = self.racesData[indexPath.row].id!
                let authKey: String? = self.defaults.stringForKey("authKey")
                
                let url = NSURL(string: "\(self.restRace)races/\(raceID)/participant?apikey=\(authKey!)")!
                var request = NSMutableURLRequest(URL: url)
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                
                request.HTTPMethod = "DELETE"
                
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                    (response, data, error) in
                    
                    let response = response as! NSHTTPURLResponse
                    if (response.statusCode == 200) {
                        self.racesData.removeAtIndex(indexPath.row)
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    }
                    else {
                        var refreshAlert = UIAlertController(title: "Mislukt", message: "Het verwijderen van de race is mislukt.", preferredStyle: UIAlertControllerStyle.Alert)
                        refreshAlert.addAction(UIAlertAction(title: "Sluiten", style: UIAlertActionStyle.Cancel) { UIAlertAction in })
                        self.presentViewController(refreshAlert, animated: true, completion: nil)
                    }
                }
            }
            alert.addAction(jaActie)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func refreshTableView() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            return
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.racesData.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var raceCell: RaceCell = self.tableView.dequeueReusableCellWithIdentifier("raceCell") as! RaceCell
        
        let visitedWaypoints = self.defaults.arrayForKey("visitedWaypoints") as! [String]
        
        var aantalVisitedWaypoints: Int = 0
        for waypoint in self.racesData[indexPath.row].waypoints {
            if (find(visitedWaypoints, waypoint.id!) != nil) {
                aantalVisitedWaypoints++
            }
        }
        
        if (aantalVisitedWaypoints < self.racesData[indexPath.row].waypoints.count) {
            raceCell.vinkje.hidden = true
        }
        
        raceCell.naam.text = self.racesData[indexPath.row].name
        raceCell.aantalWaypoints.text = String("\(aantalVisitedWaypoints)/\(self.racesData[indexPath.row].waypoints.count) waypoints")
        
        return raceCell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "toRace") {
            let indexPath = self.tableView.indexPathForSelectedRow()
            let race: Race = racesData[indexPath!.row]
            let raceController = segue.destinationViewController as! RaceController
            raceController.race = race
            raceController.hidesBottomBarWhenPushed = true;
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
