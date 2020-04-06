//
//  User.swift
//  UberApp
//
//  Created by iOS Developer on 4/1/20.
//  Copyright © 2020 iOS Developer. All rights reserved.
//
import CoreLocation

struct User {
    let uid: String
    let email: String
    let fullname: String
    var accountType: AccountType!
    var location: CLLocation?
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        if let index = dictionary["accountType"] as? Int {
            self.accountType = AccountType(rawValue: index)
        }
    }
}


enum AccountType: Int {
    case passenger
    case driver
}
