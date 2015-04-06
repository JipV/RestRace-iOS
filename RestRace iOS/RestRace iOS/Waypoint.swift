//
//  Waypoint.swift
//  RestRace iOS
//
//  Created by User on 06/04/15.
//  Copyright (c) 2015 User. All rights reserved.
//

import Foundation

class Waypoint {
    
    var id: String?
    var name: String?
    var description: String?
    var lat: Double?
    var long: Double?
    var distance: Int?
    
    init(id: String, name: String, description: String, lat: Double, long: Double, distance: Int) {
        
        self.id = id
        self.name = name
        self.description = description
        self.lat = lat
        self.long = long
        self.distance = distance
    }
    
}