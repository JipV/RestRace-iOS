//
//  RegistrerenController.swift
//  RestRace iOS
//
//  Created by Jip Verhoeven on 07/04/15.
//  Copyright (c) 2015 Jip Verhoeven. All rights reserved.
//

import UIKit

class RegistrerenController: UIViewController {
    
    @IBOutlet weak var emailadresTextField: UITextField!
    @IBOutlet weak var wachtwoordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func registreren(sender: UIButton) {
        if (!self.emailadresTextField.text.isEmpty && !self.wachtwoordTextField.text.isEmpty) {
            let url = NSURL(string: "\(MyVariables.restRace)signup")!
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
            
            // Toont melding als het registreren is mislukt
            var refreshAlert = UIAlertController(title: "Mislukt", message: "Het registreren is mislukt.\nProbeer het opnieuw.", preferredStyle: UIAlertControllerStyle.Alert)
            refreshAlert.addAction(UIAlertAction(title: "Sluiten", style: UIAlertActionStyle.Cancel) { UIAlertAction in })
            presentViewController(refreshAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onTapMainView(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

}
