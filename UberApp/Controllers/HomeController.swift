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

enum ActionButtonConfiguration {
    case showMenu
    case dismissActionView
    
    init() {
        self = .showMenu
    }
}

class HomeController: UIViewController {
    
    // MARK: - Properties
    private final let inputViewHeight: CGFloat = 200
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView: LocationInputView = {
        let inputView = LocationInputView()
        inputView.backgroundColor = .white
        inputView.alpha = 0
        return inputView
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleActionButton), for: .touchUpInside)
        return button
    }()
    
    private let tableView = UITableView()
    private var user: User? {
        didSet {
            locationInputView.user = user
        }
    }
    private var searchResults = [MKPlacemark]()
    private var actionButtonConfigure = ActionButtonConfiguration()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        enableLocationServices()
//        signOut()
    }
    
    // MARK: - Selectors
    @objc func handleActionButton() {
        switch actionButtonConfigure {
        case .dismissActionView:
            mapView.annotations.forEach { (annotation) in
                if let pointAnno = annotation as? MKPointAnnotation  {
                    mapView.removeAnnotation(pointAnno)
                }
            }
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
                self.configureAction(config: .showMenu)
            }
        case .showMenu:
            print("Show home menu")
        }
    }

    // MARK: - API
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
    
    // MARK: - Helper function
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            print("DEBUG: User not logged in")
            
            DispatchQueue.main.async {
                self.navigateToLogin()
            }
        } else {
            configure()
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
    
    func configure() {
        configureUI()
        fetchUserData()
        fetchDrivers()
    }
    
    func configureUI() {
        configureMapView()
        configureActivationView()
        configureTableView()
    }
    
    func configureAction(config: ActionButtonConfiguration) {
        switch config {
        case .dismissActionView:
            actionButton.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp-1").withRenderingMode(.alwaysOriginal), for: .normal)
            actionButtonConfigure = .dismissActionView
        case .showMenu:
            actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            actionButtonConfigure = .showMenu
        }
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
        view.addSubview(actionButton)
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                            left: view.leftAnchor,
                            paddingTop: 16,
                            paddingLeft: 20,
                            width: 30,
                            height: 30)
        
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.anchor(top: actionButton.bottomAnchor, paddingTop: 32, width: view.frame.width - 64, height: 50)
        inputActivationView.alpha = 0
        
        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1
        }
        inputActivationView.presentInputView = { [weak self] in
            self?.inputActivationView.alpha = 0
            self?.configureInputView()
        }
    }
    
    private func configureInputView() {
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 200)
        
        // Dismiss input view and display activation view
        locationInputView.delegate = self
        
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.tableView.frame.origin.y = self.inputViewHeight
            }
        }
    }
    
    private func dismissInputLocationView(completion:((Bool)->Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
            self.locationInputView.removeFromSuperview()
        }, completion: completion)
    }
}

// MARK: - Map Helper functions
private extension HomeController {
    func searchBy(naturalLanguageQuery: String, completion: @escaping([MKPlacemark]) -> Void) {
        
        var results = [MKPlacemark]()
        
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else { return }
            
            response.mapItems.forEach { (item) in
                results.append(item.placemark)
            }
            completion(results)
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

// MARK: - LocationInputView Delegate
extension HomeController: LocationInputDelegate {
    
    func dismissLocationView() {
        dismissInputLocationView { _ in
            UIView.animate(withDuration: 0.2) {
                self.inputActivationView.alpha = 1
            }
        }
    }
    
    func executeSearch(query: String) {
        print("DEBUG: query \(query)")
        searchBy(naturalLanguageQuery: query) { [weak self] (placemarks) in
            self?.searchResults = placemarks
            self?.tableView.reloadData()
        }
    }
}

// MARK: TableView Delegate & Datasource

extension HomeController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : searchResults.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        if indexPath.section == 1 {
            cell.placemark = searchResults[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlacemark = searchResults[indexPath.row]
        configureAction(config: .dismissActionView)
        dismissInputLocationView { [weak self] _ in
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedPlacemark.coordinate
            self?.mapView.addAnnotation(annotation)
            self?.mapView.selectAnnotation(annotation, animated: true)
        }
    }
}
