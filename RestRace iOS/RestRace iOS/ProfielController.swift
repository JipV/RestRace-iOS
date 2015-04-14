//
//  ProfielController.swift
//  RestRace iOS
//
//  Created by Jip Verhoeven on 06/04/15.
//  Copyright (c) 2015 Jip Verhoeven. All rights reserved.
//

import UIKit

class ProfielController: UIViewController {
    
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var nicknameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        // Toont de huidige nickname als de gebruiker een nickname heeft ingesteld
        if (MyVariables.defaults.stringForKey("nickname") != nil) {
            self.nicknameLabel.text = MyVariables.defaults.stringForKey("nickname")
            self.nicknameTextField.text = MyVariables.defaults.stringForKey("nickname")
        }
        else {
            self.nicknameLabel.text = "(Geen nickname)"
            self.nicknameTextField.text = ""
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func wijzigenNickname(sender: UIButton) {
        if (Reachability.isConnectedToNetwork()) {
            let authKey: String? = MyVariables.defaults.stringForKey("authKey")
            
            let url = NSURL(string: "\(MyVariables.restRace)users/nickname?apikey=\(authKey!)")!
            var request = NSMutableURLRequest(URL: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            request.HTTPMethod = "PUT"
            
            let jsonString = "{\"nickname\":\"\(nicknameTextField.text)\"}"
            request.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        
            // Request
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                (response, data, error) in
                
                self.response(response as! NSHTTPURLResponse)
            }
        }
        else {
            // Toont melding als er geen internet verbinding is
            var refreshAlert = UIAlertController(title: "Geen internetverbinding", message: "Er is geen internet verbinding.", preferredStyle: UIAlertControllerStyle.Alert)
            refreshAlert.addAction(UIAlertAction(title: "Sluiten", style: UIAlertActionStyle.Cancel) { UIAlertAction in })
            self.presentViewController(refreshAlert, animated: true, completion: nil)
        }
    }
    
    func response(response: NSHTTPURLResponse) {
        if (response.statusCode == 200) {
            // Slaat de gewijizgde nickname op en toont de gewijzigde nickname
            MyVariables.defaults.setObject(self.nicknameTextField.text as String, forKey: "nickname")
            self.nicknameLabel.text = MyVariables.defaults.stringForKey("nickname")
            self.nicknameTextField.text = MyVariables.defaults.stringForKey("nickname")
        }
        else {
            // Toont een melding als het wijzigen van de nickname is mislukt
            var refreshAlert = UIAlertController(title: "Mislukt", message: "Het wijzigen van de nickname is mislukt.\nProbeer het opnieuw.", preferredStyle: UIAlertControllerStyle.Alert)
            refreshAlert.addAction(UIAlertAction(title: "Sluiten", style: UIAlertActionStyle.Cancel) { UIAlertAction in })
            presentViewController(refreshAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onTapMainView(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

}
