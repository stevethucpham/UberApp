//
//  HomeController.swift
//  UberApp
//
//  Created by iOS Developer on 3/31/20.
//  Copyright © 2020 iOS Developer. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreLocation


class HomeController: UIViewController {
    
    // MARK: - Properties
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        checkIfUserIsLoggedIn()
//        signOut()
        checkIfUserIsLoggedIn()
        enableLocationServices()
    }
    
    // MARK: - Selectors
    
    // MARK: - Helper function
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            print("DEBUG: User not logged in")
            
            DispatchQueue.main.async {
                self.navigateToLogin()
            }
        } else {
            configureUI()
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("DEBUG: Error signing out")
        }
    }
    
    private func navigateToLogin() {
        let navigationController = UINavigationController(rootViewController: LoginController())
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
    func configureUI() {
        configureMapView()
    }
    
    private func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
}

// MARK: - Location Services
extension HomeController: CLLocationManagerDelegate {
    
    func enableLocationServices() {
        
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("DEBUG: Not determined")
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted, .denied:
            break
        case .authorizedAlways:
            print("DEBUG: Always allow")
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            break
        case .authorizedWhenInUse:
            print("DEBUG: Authen when in use")
            locationManager.requestAlwaysAuthorization()
            break
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
}
