//
//  User.swift
//  playersMeetup
//
//  Created by Yazan Arafeh on 5/3/20.
//  Copyright © 2020 Nada Zeini. All rights reserved.
//

import Foundation

struct UserInfo {
    var username: String
    var name: String
    var bio: String
    var photoURL: String
    
    init(username: String?, name: String?, bio: String?, photoURL: String?) {
        self.username = username ?? ""
        self.name = name ?? ""
        self.bio = bio ?? ""
        self.photoURL = photoURL ?? ""
    }
    
    func asDictionary() -> Dictionary<String, String> {
        return ["username": self.username,
                "name": self.name,
                "bio": self.bio,
                "photoURL": self.photoURL
        ]
    }
}
