//
//  Race.swift
//  RestRace iOS
//
//  Created by User on 05/04/15.
//  Copyright (c) 2015 User. All rights reserved.
//

import Foundation

class Race {
    
    var id: String?
    var name: String?
    var isPrivate: Bool?
    var startTime: String?
    var endTime: String?
    var owners: [String] = []
    var participants: [String] = []
    var waypoints: [Waypoint] = []

    init (id: String, name: String, isPrivate: Bool, startTime: String, endTime: String?, owners: [String], participants: [String], waypoints: [Waypoint]) {
        
        self.id = id
        self.name = name
        self.isPrivate = isPrivate
        self.startTime = startTime
        self.endTime = endTime
        self.owners = owners
        self.participants = participants
        self.waypoints = waypoints
    }

}