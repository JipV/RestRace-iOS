//
//  DeelnemenController.swift
//  RestRace iOS
//
//  Created by Jip Verhoeven on 10/04/15.
//  Copyright (c) 2015 User. All rights reserved.
//

import UIKit

class DeelnemenController: UIViewController {

    let restRace: String = "https://restrace2.herokuapp.com/"
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var codeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func deelnemenAanRace(sender: UIButton) {
        if (!self.codeTextField.text.isEmpty) {
            
            /*let raceID: String = self.codeTextField.text
            let authKey: String? = defaults.stringForKey("authKey")
            
            let url = NSURL(string: "\(restRace)races/\(raceID)/participant")!
            var request = NSMutableURLRequest(URL: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            request.HTTPMethod = "PUT"
            
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                (response, data, error) in
                
                var parseError: NSError?
                let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data,
                    options: NSJSONReadingOptions.AllowFragments,
                    error:&parseError)
                
                // Check of het is gelukt
                // Zo ja toon races pagina, zo nee geef melding en maak tekst veld leeg
                //self.getUserFromJSON(parsedObject as! NSDictionary)
            }*/
            
            
            
            
            navigationController?.popViewControllerAnimated(true)
            self.codeTextField.text = ""
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
