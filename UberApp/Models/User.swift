//
//  User.swift
//  UberApp
//
//  Created by iOS Developer on 4/1/20.
//  Copyright © 2020 iOS Developer. All rights reserved.
//

struct User {
    let email: String
    let fullname: String
    let accountType: Int
    
    init(dictionary: [String: Any]) {
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.accountType = dictionary["accountType"] as? Int ?? 0
    }
}
