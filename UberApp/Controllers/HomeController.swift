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


private let reuseIdentifier = "LocationCell"
private let annotationIdentifier = "DriverAnnotation"

class HomeController: UIViewController {
    
    // MARK: - Properties
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView: LocationInputView = {
        let inputView = LocationInputView()
        inputView.backgroundColor = .white
        inputView.alpha = 0
        return inputView
    }()
    
    private let tableView = UITableView()
    
    private final let inputViewHeight: CGFloat = 200
    
    private var user: User? {
        didSet {
            locationInputView.user = user
        }
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        enableLocationServices()
        fetchUserData()
        fetchDrivers()
//        signOut()
    }
    
    // MARK: - Selectors
    
    // MARK: - Helper function
    
    private func fetchUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Service.shared.fetchUserData(uid: currentUid) { [weak self] (user) in
            self?.user = user
        }
    }
    
    private func fetchDrivers() {
        guard let location = locationManager?.location else { return }
        Service.shared.fetchDrivers(location: location) {
            driver in
            print("DEBUG: Driver name \(driver.fullname)")
            guard let coordinate = driver.location?.coordinate else { return }
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            
            var driverIsVisible: Bool {
                return self.mapView.annotations.contains { annotation -> Bool in
                    guard let driverAnnotation = annotation as? DriverAnnotation else { return false }
                    if driverAnnotation.uid == driver.uid {
                        driverAnnotation.updatePosition(with: coordinate)
                        return true
                    }
                    return false
                }
            }
            if !driverIsVisible {
                self.mapView.addAnnotation(annotation)
            }
            
        }
    }
    
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
            DispatchQueue.main.async {
                self.navigateToLogin()
            }
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
        configureActivationView()
        configureTableView()
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        
        let height = view.frame.height - inputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        view.addSubview(tableView)
    }
    
    private func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
    }
    
    private func configureActivationView() {
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32, width: view.frame.width - 64, height: 50)
        inputActivationView.alpha = 0
        
        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1
        }
        inputActivationView.presentInputView = { [weak self] in
            print("DEBUG: Handle present location input view")
            self?.inputActivationView.alpha = 0
            self?.configureInputView()
        }
    }
    
    private func configureInputView() {
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 200)
        
        // Dismiss input view and display activation view
        locationInputView.dismissLocationHandler = {
            UIView.animate(withDuration: 0.3, animations: {
                self.locationInputView.alpha = 0
                self.tableView.frame.origin.y = self.view.frame.height
            }) { _ in
                self.locationInputView.removeFromSuperview()
                UIView.animate(withDuration: 0.3) {
                    self.inputActivationView.alpha = 1
                }
            }
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.locationInputView.alpha = 1
        }) { _ in
            print("DEBUG: Display table view")
            UIView.animate(withDuration: 0.3) {
                self.tableView.frame.origin.y = self.inputViewHeight
            }
        }
    }
}

// MARK: - Map View Delegate
extension HomeController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let driverAnnonation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: driverAnnonation, reuseIdentifier: annotationIdentifier)
            view.image = #imageLiteral(resourceName: "chevron-sign-to-right")
            
            return view
        }
        return nil
    }
}

// MARK: - Location Services
extension HomeController {
    
    func enableLocationServices() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("DEBUG: Not determined")
            locationManager?.requestWhenInUseAuthorization()
            break
        case .restricted, .denied:
            break
        case .authorizedAlways:
            print("DEBUG: Always allow")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            break
        case .authorizedWhenInUse:
            print("DEBUG: Authen when in use")
            locationManager?.requestAlwaysAuthorization()
            break
        @unknown default:
            break
        }
    }
    
}

// MARK: TableView Delegate & Datasource

extension HomeController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 5
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        return cell
    }
    
}
