//
//  User.swift
//  RestRace iOS
//
//  Created by User on 08/04/15.
//  Copyright (c) 2015 User. All rights reserved.
//

import Foundation

class User {
    
    var authKey: String?
    var nickname: String?
    var visitedWaypoints: [String] = []
    
    init (authKey: String, nickname: String?, visitedWaypoints: [String]) {
        self.authKey = authKey
        self.nickname = nickname
        self.visitedWaypoints = visitedWaypoints
    }
    
}