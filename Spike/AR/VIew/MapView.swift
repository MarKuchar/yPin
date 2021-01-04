//
//  MapVIew.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-10-28.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit
import MapKit

class MapView: MKMapView {

    private let locationManager = CLLocationManager()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            checkLocationServices()
            //        let singleTapRecognizer = UITapGestureRecognizer(target: self, action: nil)
            //        singleTapRecognizer.delegate = self
            //        self.addGestureRecognizer(singleTapRecognizer)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func checkLocationServices() {
            if CLLocationManager.locationServicesEnabled() {
                checkLocationAuthorization()
                locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            } else {
                // Show alert letting the user know they have to turn this on.
            }
        }

        private func checkLocationAuthorization() {
            switch locationManager.authorizationStatus {
                case .authorizedWhenInUse:
                    self.showsUserLocation = true
                case .denied: // Show alert telling users how to turn on permissions
                    break
                case .notDetermined:
                    locationManager.requestWhenInUseAuthorization()
                    self.showsUserLocation = true
                case .restricted: // Show an alert letting them know what’s up
                    break
                case .authorizedAlways:
                    break
                default: break
            }
        }
    }

    extension MKMapView {
        func centerToLocation(
            _ location: CLLocation,
            regionRadius: CLLocationDistance = 8000
        ) {
            let coordinateRegion = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: regionRadius,
                longitudinalMeters: regionRadius)
            setRegion(coordinateRegion, animated: true)
        }
}
