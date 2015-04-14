//
//  DeelnemenController.swift
//  RestRace iOS
//
//  Created by Jip Verhoeven on 10/04/15.
//  Copyright (c) 2015 Jip Verhoeven. All rights reserved.
//

import UIKit

class DeelnemenController: UIViewController {

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
            let authKey: String? = MyVariables.defaults.stringForKey("authKey")
            
            let url = NSURL(string: "\(MyVariables.restRace)races/\(raceID)/participant?apikey=\(authKey!)")!
            var request = NSMutableURLRequest(URL: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            request.HTTPMethod = "PUT"
            
            // Request
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                (response, data, error) in
        
                self.response(response as! NSHTTPURLResponse)
            }
        }
    }
    
    func response(response: NSHTTPURLResponse) {
        if (response.statusCode == 200) {
            // Toont races overzicht
            navigationController?.popViewControllerAnimated(true)
        }
        else {
            // Geeft melding dat het deelnemen aan de race is mislukt
            var refreshAlert = UIAlertController(title: "Mislukt", message: "Het deelnemen aan de race is mislukt.\nProbeer het opnieuw.", preferredStyle: UIAlertControllerStyle.Alert)
            refreshAlert.addAction(UIAlertAction(title: "Sluiten", style: UIAlertActionStyle.Cancel) { UIAlertAction in })
            presentViewController(refreshAlert, animated: true, completion: nil)  
        }
    }
    
    @IBAction func onTapMainView(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

}
