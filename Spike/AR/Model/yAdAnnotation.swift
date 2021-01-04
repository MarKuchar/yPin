//
//  AdAnnotation.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-10-28.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import Foundation
import MapKit
import Contacts

public struct Location {
    var lat: Double
    var lon: Double
}

public class yAdAnnotation: NSObject, MKAnnotation {
    public var title: String?
    var location: GeoLocation
    var image: String?
    var content: String?
    var adType: String?
    public var coordinate: CLLocationCoordinate2D
    
    var mapItem: MKMapItem? {
        let addressDict = [CNPostalAddressStreetKey: subtitle!]
        let placemark = MKPlacemark(
            coordinate: coordinate,
            addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
    
    init(title: String, location: GeoLocation, image: String? = nil) {
        self.title = title
        self.location = location
        self.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        self.image = image
        
        super.init()
    }
    
    public var subtitle: String? {
        return title
    }
}

