//
//  ProfielController.swift
//  RestRace iOS
//
//  Created by User on 06/04/15.
//  Copyright (c) 2015 User. All rights reserved.
//

import UIKit

class ProfielController: UIViewController {
    
    let restRace: String = "https://restrace2.herokuapp.com/"
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var nicknameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //if (defaults.stringForKey("nickname") != nil) {
            self.nicknameTextField.text = defaults.stringForKey("nickname")
        //}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func wijzigenNickname(sender: UIButton) {
        if (!self.nicknameTextField.text.isEmpty) {
            
            let userID: String? = defaults.stringForKey("id")
            let authKey: String? = defaults.stringForKey("authKey")
            
            let url = NSURL(string: "\(restRace)users/nickname?apikey=\(authKey!)")!
            var request = NSMutableURLRequest(URL: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            request.HTTPMethod = "PUT"
            
            let jsonString = "{\"nickname\":\"\(nicknameTextField.text)\"}"
            request.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
            
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                (response, data, error) in
                
                self.response(response as! NSHTTPURLResponse)
            }
        }
    }
    
    func response(response: NSHTTPURLResponse) {
        println("status code \(response.statusCode)")
        if (response.statusCode == 200) {
            println("Nickname is gewijzigd")
            defaults.setObject(self.nicknameTextField.text as String, forKey: "nickname")
        }
        else {
            var refreshAlert = UIAlertController(title: "Mislukt", message: "Het wijzigen van de nickname is mislukt.\nProbeer het opnieuw.", preferredStyle: UIAlertControllerStyle.Alert)
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
