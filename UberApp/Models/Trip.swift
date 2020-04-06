//
//  Trip.swift
//  UberApp
//
//  Created by iOS Developer on 4/6/20.
//  Copyright © 2020 iOS Developer. All rights reserved.
//

import CoreLocation

struct Trip {
    var pickupCoordinates, destinationCoordinates: CLLocationCoordinate2D!
    let passengerUid: String
    var driverUid: String?
    var tripState: TripState!
    
    init (passengerUid: String, dictionary: [String:Any]) {
        self.passengerUid = passengerUid
        if let pickupCoordiate = dictionary["pickupCoordiate"] as? NSArray {
            guard let lat = pickupCoordiate[0] as? CLLocationDegrees else { return }
            guard let long = pickupCoordiate[1] as? CLLocationDegrees else { return }
            
            self.pickupCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        if let destinationCoordinates = dictionary["destinationCoordiates"] as? NSArray {
            
            guard let lat = destinationCoordinates[0] as? CLLocationDegrees else { return }
            guard let long = destinationCoordinates[1] as? CLLocationDegrees else { return }
            
            self.destinationCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        self.driverUid = dictionary["driverUid"] as? String ?? ""
        if let state = dictionary["state"] as? Int {
            self.tripState = TripState(rawValue: state)
        }
    }
}

enum TripState: Int {
    case requested
    case accepted
    case inProgress
    case completed
}
