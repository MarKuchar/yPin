//
//  CLPlacemark+Addition.swift
//  GreenWanderer
//
//  Created by Martin Kuchar on 2020-09-16.
//

import CoreLocation

extension CLPlacemark {
  var abbreviation: String {
    if let name = self.name {
      return name
    }

    if let interestingPlace = areasOfInterest?.first {
      return interestingPlace
    }

    return [subThoroughfare, thoroughfare].compactMap { $0 }.joined(separator: " ")
  }
}
