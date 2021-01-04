//
//  yMapSetLocationViewController.swift
//  Spike
//
//  Created by Cayo on 2020-12-27.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class yMapSetLocationViewController: UIViewController {
    
    private let mapView: MapView = MapView()
    private let identifier = "adAnnotation"
    private var currentLocation: CLLocationCoordinate2D?
    
    weak var delegate: yMapSetLocationViewControllerDelegate?
    
    fileprivate let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        return manager
    }()
    
    lazy var setLocationBtn: UIButton = {
        let btn = yButton.init(text: "Set Location")
        btn.addAction(.init(handler: { _ in
            guard let location = self.currentLocation else {
                self.showToast(message: "Location unavailable!")
                return
            }
            self.delegate?.locationSelected(location)
            self.navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
        return btn
    }()
    
    let pin: UIView = {
        let v = UIImageView.init(image: UIImage.init(named: "Saved"))
        v.translatesAutoresizingMaskIntoConstraints = false
        v.dimensions(withSize: .buttonIconSize)
        return v
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        determineCurrentLocation()
        mapView.showsUserLocation = true
        mapView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapViewSetup()
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    private func setupView() {
        view.addSubview(setLocationBtn)
        self.view.addSubview(self.pin)
        let pinOffset = -UIConstants.Button.buttonIconSize.height / 2
        NSLayoutConstraint.activate([
            setLocationBtn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            setLocationBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            self.pin.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.pin.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: pinOffset)
        ])
        
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
        
        var location = CLLocation(latitude: 49.2827, longitude: -123.1207) // Vancouver
//        if let userLocation = locationManager.location?.coordinate {
//            location = userLocation
//        }
        mapView.centerToLocation(location)
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

extension yMapSetLocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.currentLocation = mapView.centerCoordinate
    }
    
}

extension yMapSetLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let currentLocation = locations.last?.coordinate {
            let coordinateRegion = MKCoordinateRegion(center: currentLocation, latitudinalMeters: 800, longitudinalMeters: 800)
            mapView.setRegion(coordinateRegion, animated: true)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error requesting location: \(error.localizedDescription)")
    }
}

protocol yMapSetLocationViewControllerDelegate: class {
    func locationSelected(_ location: CLLocationCoordinate2D)
}
