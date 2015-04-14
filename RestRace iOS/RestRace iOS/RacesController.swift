//
//  RacesController.swift
//  RestRace iOS
//
//  Created by Jip Verhoeven on 03/04/15.
//  Copyright (c) 2015 Jip Verhoeven. All rights reserved.
//

import UIKit

class RacesController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var racesData: [Race] = []
    
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Toont inlogscherm als de gebruiker niet is ingelogd
        let authKey: String? = MyVariables.defaults.stringForKey("authKey")
        if (authKey == nil) {
            self.performSegueWithIdentifier("toLogin", sender: self)
        }
        
        // Voegt een activity indicator toe aan de view
        activityIndicator.frame = CGRectMake(100, 100, 100, 100);
        self.view.addSubview(activityIndicator)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Zorgt ervoor dat lege rijen niet worden getoond
        var backgroundView = UIView(frame: CGRectZero)
        self.tableView.tableFooterView = backgroundView
        self.tableView.backgroundColor = UIColor.clearColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        // Haalt de gegevens opniew op en refresht de tableview
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

        // Gooit de opgeslagen gegevens van de gebruiker leeg
        MyVariables.defaults.setObject(nil, forKey: "authKey")
        MyVariables.defaults.setObject(nil, forKey: "nickname")
        MyVariables.defaults.setObject(nil, forKey: "visitedWaypoints")
        
        // Toont inlogscherm
        self.performSegueWithIdentifier("toLogin", sender: self)
    }
    
    func getRacesData() {
        let authKey: String? = MyVariables.defaults.stringForKey("authKey")
        if (authKey != nil) {
            activityIndicator.startAnimating()
            
            let url = NSURL(string: "\(MyVariables.restRace)races?apikey=\(authKey!)&type=participant&pageSize=100")!
            var request = NSMutableURLRequest(URL: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        
            // Request
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                (response, data, error) in
            
                // Parse JSON
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
            
            // Verzamelt id's van de owners
            var ownersArray: [String] = []
            for owner in race["owners"] as! NSArray {
                ownersArray.append(owner["_id"] as! NSString as String)
            }
            
            // Verzamelt id's van de pariticipants
            var participantsArray: [String] = []
            for participant in race["participants"] as! NSArray {
                participantsArray.append(participant["_id"] as! NSString as String)
            }
            
            // Verzamelt de informatie van de waypoints
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
            
            // Verzamelt de informatie van een race
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
            
            // Geeft een melding als de gebruiker een race wilt verwijderen
            let alert = UIAlertController(title: "Race verwijderen", message: "Weet u zeker dat u de race wilt verwijderen? U bent dan geen deelnemer meer van de race.", preferredStyle: .Alert)
            
            let neeActie = UIAlertAction(title: "Nee", style: .Cancel, handler: nil)
            alert.addAction(neeActie)
            
            let jaActie = UIAlertAction(title: "Ja", style: .Default) { (action) in
                
                let raceID: String = self.racesData[indexPath.row].id!
                let authKey: String? = MyVariables.defaults.stringForKey("authKey")
                
                let url = NSURL(string: "\(MyVariables.restRace)races/\(raceID)/participant?apikey=\(authKey!)")!
                var request = NSMutableURLRequest(URL: url)
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                
                request.HTTPMethod = "DELETE"
                
                // Request
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                    (response, data, error) in
                    
                    let response = response as! NSHTTPURLResponse
                    if (response.statusCode == 200) {
                        // Verwijdert de race uit de tableview
                        self.racesData.removeAtIndex(indexPath.row)
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    }
                    else {
                        // Geeft een melding als het verwijderen van de race is mislukt
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
        // Vernieuwt de data in de tableview
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            return
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var label = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        if (self.racesData.count == 0) {
            
            // Toont bericht als er geen races zijn waar de ingelogde gebruiker aan deelneemt
            label.text = "Er zijn geen races waar u aan deelneemt."
            label.textAlignment = NSTextAlignment.Center
            label.numberOfLines = 0
            self.tableView.backgroundView = label
            
            return 0
        }
        self.tableView.backgroundView = nil
        return self.racesData.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var raceCell: RaceCell = self.tableView.dequeueReusableCellWithIdentifier("raceCell") as! RaceCell
        
        let visitedWaypoints = MyVariables.defaults.arrayForKey("visitedWaypoints") as! [String]
        
        // Bepaalt de status van een race
        var aantalVisitedWaypoints: Int = 0
        for waypoint in self.racesData[indexPath.row].waypoints {
            if (find(visitedWaypoints, waypoint.id!) != nil) {
                aantalVisitedWaypoints++
            }
        }
        
        // Toont de status van een race
        if (aantalVisitedWaypoints < self.racesData[indexPath.row].waypoints.count) {
            raceCell.vinkje.hidden = true
        }
        
        raceCell.naam.text = self.racesData[indexPath.row].name
        raceCell.aantalWaypoints.text = String("\(aantalVisitedWaypoints)/\(self.racesData[indexPath.row].waypoints.count) waypoints")
        
        return raceCell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "toRace") {
            // Toont de info van een race
            let indexPath = self.tableView.indexPathForSelectedRow()
            let race: Race = racesData[indexPath!.row]
            let raceController = segue.destinationViewController as! RaceController
            raceController.race = race
            raceController.hidesBottomBarWhenPushed = true;
        }
    }

}
