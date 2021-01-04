//
//  MapViewController.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-10-28.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class yMapViewController: UIViewController {
    
    private lazy var authUser = Auth.auth().currentUser!
    private lazy var docRef = Firestore.firestore().collection("users").document(authUser.uid)
    
    private let mapView: MapView = MapView()
    private let identifier = "adAnnotation"
    private var ads: [Ad]!
    private let userDocumentRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
    
    fileprivate let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        return manager
    }()
    
    lazy var profileBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "UserIcon.png"), for: .normal)
        btn.constraintHeight(equalToConstant: 44)
        btn.constraintWidth(equalToConstant: 44)
        return btn
    }()
    
    lazy var addAdBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "Add.png"), for: .normal)
        btn.dimensions(withSize: .buttonIconSize)
        btn.isHidden = true
        return btn
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        determineCurrentLocation()
        mapView.showsUserLocation = true;
        
        docRef.getDocument { (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            if let snap = snap {
                if let data = try? snap.data(as: User.self) {
                    self.addAdBtn.isHidden = !data.premium
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapViewSetup()
        
        let currentLocation = GeoLocation(latitude: 49.282295, longitude: -123.125953)
        // When using real device
        //            latitude: locationManager.location!.coordinate.latitude,
        //            longitude: locationManager.location!.coordinate.longitude)
        
        RepositoryFactory.createAdRepository().fetchTop(from: currentLocation, completion: { topAds in
            let adAnnotations: [yAdAnnotation] = topAds.map { ad in
                let adkAnnotation = yAdAnnotation(
                    title: ad.content!,
                    location: GeoLocation(latitude: ad.geoLocation!.latitude, longitude: ad.geoLocation!.longitude))
                
                // Should be setting for notification in the Main thread?
                let center = CLLocationCoordinate2D(latitude: ad.geoLocation!.latitude, longitude: ad.geoLocation!.longitude)
                let region = CLCircularRegion(center: center, radius: 1.0, identifier: "AdArea")
                region.notifyOnEntry = true
                region.notifyOnExit = false
                let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
                self.notificationRequest(trigger: trigger)
                return adkAnnotation
            }
            // Loop through fetched ads and place them on the map
            DispatchQueue.main.async {
                for annotation in adAnnotations {
                    self.mapView.addAnnotation(annotation)
                }
            }
        })
        
        setupView()
        profileBtn.addTarget(self, action: #selector(navigateToProfileView(_ :)), for: .touchUpInside)
        addAdBtn.addTarget(self, action: #selector(navigateToAddAdvertisementView(_ :)), for: .touchUpInside)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    private func setupView() {
        view.addSubview(profileBtn)
        NSLayoutConstraint.activate([
            profileBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            profileBtn.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
        view.addSubview(addAdBtn)
        NSLayoutConstraint.activate([
            addAdBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addAdBtn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    @objc func navigateToProfileView(_ btn: UIButton) {
        let profileView = ProfileViewController()
        navigationController?.pushViewController(profileView, animated: true)
    }
    
    @objc func navigateToAddAdvertisementView(_ btn: UIButton) {
        let addAdView = yAddAdViewController.init()
//        navigationController?.present(addAdView, animated: true) {
//            self.refreshMap()
//        }
        
//        let transation = CATransition.init()
//        transation.duration = 0.5
//        transation.timingFunction = .init(name: .easeInEaseOut)
//        transation.type = .push
//        transation.subtype = .fromTop
//        self.navigationController?.view.layer.add(transation, forKey: kCATransition)
        self.navigationController?.pushViewController(addAdView, animated: true)
    }
    
    func refreshMap() {
        // TODO refresh the map
    }
    
    private func notificationRequest(trigger: UNLocationNotificationTrigger) {
        let notification = UNMutableNotificationContent()
        notification.title = "You've entered the area with the Pin"
        notification.sound = .default
        
        let request = UNNotificationRequest(identifier: "destAlarm", content: notification, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if error == nil {
                print("Successful notification")
            } else {
                print(error ?? "Error")
            }
        })
    }
    
    private func mapViewSetup() {
        view.addSubview(mapView)
        mapView.matchParent()
        
        let vancouverLocation = CLLocation(latitude: 49.2827, longitude: -123.1207)
        mapView.centerToLocation(vancouverLocation)
    }
    
    // MARK:- Location manager methods
    
    func determineCurrentLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
}

// MARK:- Map view delegate

extension yMapViewController: MKMapViewDelegate {
    func mapView(
        _ mapView: MKMapView,
        viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? yAdAnnotation else {
            return nil
        }
        
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(
            withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(
                annotation: annotation,
                reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
}

extension yMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            let currentLocation = location.coordinate
            let coordinateRegion = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 800, longitudinalMeters: 800)
            mapView.setRegion(coordinateRegion, animated: true)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error requesting location: \(error.localizedDescription)")
    }
}
