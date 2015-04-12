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
            
            let raceID: String = self.codeTextField.text
            let authKey: String? = defaults.stringForKey("authKey")
            
            let url = NSURL(string: "\(restRace)races/\(raceID)/participant?apikey=\(authKey!)")!
            var request = NSMutableURLRequest(URL: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            request.HTTPMethod = "PUT"
            
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                (response, data, error) in
        
                self.response(response as! NSHTTPURLResponse)
            }
        }
    }
    
    func response(response: NSHTTPURLResponse) {
        if (response.statusCode == 200) {
            navigationController?.popViewControllerAnimated(true)
        }
        else {
            var refreshAlert = UIAlertController(title: "Mislukt", message: "Het deelnemen aan de race is mislukt.\nProbeer het opnieuw.", preferredStyle: UIAlertControllerStyle.Alert)
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
