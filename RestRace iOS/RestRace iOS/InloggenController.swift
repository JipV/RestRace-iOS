//
//  InloggenController.swift
//  RestRace iOS
//
//  Created by Jip Verhoeven on 06/04/15.
//  Copyright (c) 2015 Jip Verhoeven. All rights reserved.
//

import UIKit
import Foundation

class InloggenController: UIViewController {
    
    @IBOutlet weak var emailadresTextField: UITextField!
    @IBOutlet weak var wachtwoordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func inloggen(sender: UIButton) {
        if (Reachability.isConnectedToNetwork()) {
            if (!self.emailadresTextField.text.isEmpty && !self.wachtwoordTextField.text.isEmpty) {
                let url = NSURL(string: "\(MyVariables.restRace)login")!
                var request = NSMutableURLRequest(URL: url)
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
                request.HTTPMethod = "POST"
        
                let jsonString = "{\"email\":\"\(self.emailadresTextField.text)\",\"password\":\"\(self.wachtwoordTextField.text)\"}"
                request.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        
                // Request
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                    (response, data, error) in
            
                    // Parse JSON
                    var parseError: NSError?
                    let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data,
                        options: NSJSONReadingOptions.AllowFragments,
                        error:&parseError)
            
                    self.getUserFromJSON(parsedObject as! NSDictionary)
                }
            }
        }
        else {
            // Toont melding als er geen internet verbinding is
            var refreshAlert = UIAlertController(title: "Geen internetverbinding", message: "Er is geen internet verbinding.", preferredStyle: UIAlertControllerStyle.Alert)
            refreshAlert.addAction(UIAlertAction(title: "Sluiten", style: UIAlertActionStyle.Cancel) { UIAlertAction in })
            self.presentViewController(refreshAlert, animated: true, completion: nil)
        }
    }
    
    func getUserFromJSON(user: NSDictionary) {
        if (user["authKey"] as? String != nil) {
            // Verzamelt de visited waypoints van de ingelogde op
            var visitedWaypointsArray: [String] = []
            for visitedWaypoint in user["visitedLocations"] as! NSArray {
                let waypoint = visitedWaypoint as! NSDictionary
                visitedWaypointsArray.append(visitedWaypoint["location"] as! String)
            }
            
            // Slaat de gegevens van de ingelogde gebruiker op
            MyVariables.defaults.setObject(user["authKey"] as! String, forKey: "authKey")
            MyVariables.defaults.setObject(user["nickname"] as? String, forKey: "nickname")
            MyVariables.defaults.setObject(visitedWaypointsArray, forKey: "visitedWaypoints")
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            self.wachtwoordTextField.text = ""

            // Toont melding als het inloggen is mislukt
            var refreshAlert = UIAlertController(title: "Mislukt", message: "Het inloggen is mislukt.\nProbeer het opnieuw.", preferredStyle: UIAlertControllerStyle.Alert)
            refreshAlert.addAction(UIAlertAction(title: "Sluiten", style: UIAlertActionStyle.Cancel) { UIAlertAction in })
            presentViewController(refreshAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onTapMainView(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

}
