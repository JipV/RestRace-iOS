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
    
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var nicknameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        if (defaults.stringForKey("nickname") != nil) {
            self.nicknameLabel.text = defaults.stringForKey("nickname")
            self.nicknameTextField.text = defaults.stringForKey("nickname")
        }
        else {
            self.nicknameLabel.text = "(Geen nickname ingesteld)"
            self.nicknameTextField.text = ""
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func wijzigenNickname(sender: UIButton) {
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
    
    func response(response: NSHTTPURLResponse) {
        if (response.statusCode == 200) {
            defaults.setObject(self.nicknameTextField.text as String, forKey: "nickname")
            self.nicknameLabel.text = defaults.stringForKey("nickname")
            self.nicknameTextField.text = defaults.stringForKey("nickname")
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
