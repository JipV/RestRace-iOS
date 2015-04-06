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
    let authKey: String = "c53cf930-3829-4ed0-808a-b54d80cbcdde"
    
    var racesData: [Race] = []
    
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.performSegueWithIdentifier("toLogin", sender: self)
        
        
        activityIndicator.frame = CGRectMake(100, 100, 100, 100);
        self.view.addSubview(activityIndicator)
        
        getRacesData()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        var nib = UINib(nibName: "RaceCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "raceCell")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getRacesData() {
        activityIndicator.startAnimating()
        
        let url = NSURL(string: "\(restRace)races?apikey=\(authKey)&type=participating")!
        var request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
            (response, data, error) in
            
            var parseError: NSError?
            let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.AllowFragments,
                error:&parseError)
            
            self.getRacesDataFromJSON(parsedObject as NSArray)
        }
    }
    
    func getRacesDataFromJSON(races: NSArray) {
        for race in races {
                
            var ownersArray: [String] = []
            for owner in race["owners"] as NSArray {
                ownersArray.append(owner["_id"] as NSString)
            }
                
            var participantsArray: [String] = []
            for participant in race["participants"] as NSArray {
                participantsArray.append(participant["_id"] as NSString)
            }
                
            var waypointsArray: [Waypoint] = []
            for waypoint in race["locations"] as NSArray {
                let location = waypoint["location"] as NSDictionary
                let newWaypoint = Waypoint(
                    id: waypoint["_id"] as String,
                    name: location["name"] as String,
                    description: location["description"] as String,
                    lat: location["lat"] as Double,
                    long: location["long"] as Double,
                    distance: location["distance"] as Int
                )
                waypointsArray.append(newWaypoint)
            }
            
            let newRace = Race(
                id: race["_id"] as String,
                name: race["name"] as String,
                isPrivate: race["private"] as Bool,
                startTime: race["startTime"] as String,
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
    
    /*func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("toChat", sender: tableView.cellForRowAtIndexPath(indexPath))
    }*/
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var raceCell: RaceCell = self.tableView.dequeueReusableCellWithIdentifier("raceCell") as RaceCell
        raceCell.naam.text = self.racesData[indexPath.row].name
        raceCell.aantalWaypoints.text = String("\(self.racesData[indexPath.row].waypoints.count) waypoints")
        return raceCell
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
