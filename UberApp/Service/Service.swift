//
//  Service.swift
//  UberApp
//
//  Created by iOS Developer on 4/1/20.
//  Copyright © 2020 iOS Developer. All rights reserved.
//

import Firebase

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")

struct Service {
    
    static let shared = Service()
    
    private init() { }
    
    let currentUid = Auth.auth().currentUser?.uid
    
    func fetchUserData(completion: @escaping(User) -> ()) {
        REF_USERS.child(currentUid!).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            print(dictionary)
            let user = User(dictionary: dictionary)
            completion(user)
        }
    }
}
