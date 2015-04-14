//
//  WaypointController.swift
//  RestRace iOS
//
//  Created by Jip Verhoeven on 10/04/15.
//  Copyright (c) 2015 Jip Verhoeven. All rights reserved.
//

import UIKit
import MapKit

class WaypointController: UIViewController {
    
    @IBOutlet weak var naamLabel: UILabel!
    @IBOutlet weak var omschrijvingLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var waypoint: Waypoint?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.naamLabel.text = self.waypoint!.name!
        self.waypoint!.description != nil ? (self.omschrijvingLabel.text = "Omschrijving:\n\(self.waypoint!.description!)") : (self.omschrijvingLabel.text = "")
        
        // Toont locatie op kaart
        let location = CLLocationCoordinate2D(latitude: waypoint!.lat!, longitude: waypoint!.long!)
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        // Toont marker op kaart
        let marker = MKPointAnnotation()
        marker.coordinate = location
        marker.title = waypoint!.name!
        mapView.addAnnotation(marker)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
