//
//  RegistrerenController.swift
//  RestRace iOS
//
//  Created by User on 07/04/15.
//  Copyright (c) 2015 User. All rights reserved.
//

import UIKit

class RegistrerenController: UIViewController {

    let restRace: String = "https://restrace2.herokuapp.com/"
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var emailadresTextField: UITextField!
    @IBOutlet weak var wachtwoordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func registreren(sender: UIButton) {
        if (!emailadresTextField.text.isEmpty && !wachtwoordTextField.text.isEmpty) {
            let url = NSURL(string: "\(restRace)signup")!
            var request = NSMutableURLRequest(URL: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
            request.HTTPMethod = "POST"
        
            let jsonString = "{\"email\":\"\(emailadresTextField.text)\",\"password\":\"\(wachtwoordTextField.text)\"}"
            request.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                (response, data, error) in
            
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
            var visitedWaypointsArray: [String] = []
            for visitedWaypoint in user["visitedLocations"] as! NSArray {
                let waypoint = visitedWaypoint as! NSDictionary
                visitedWaypointsArray.append(visitedWaypoint["location"] as! String)
            }
            
            defaults.setObject(user["_id"] as! String, forKey: "id")
            defaults.setObject(user["authKey"] as! String, forKey: "authKey")
            defaults.setObject(user["nickname"] as? String, forKey: "nickname")
            defaults.setObject(visitedWaypointsArray, forKey: "visitedWaypoints")
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            wachtwoordTextField.text = ""
            
            var refreshAlert = UIAlertController(title: "Mislukt", message: "Het registreren is mislukt.\nProbeer het opnieuw.", preferredStyle: UIAlertControllerStyle.Alert)
            refreshAlert.addAction(UIAlertAction(title: "Sluiten", style: UIAlertActionStyle.Cancel) { UIAlertAction in })
            presentViewController(refreshAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onTapMainView(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
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
