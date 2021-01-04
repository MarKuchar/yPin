//
//  FloatingPoint.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-11-09.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import Foundation

extension FloatingPoint {
    func toRadians() -> Self {
        return self * .pi / 180
    }

    func toDegrees() -> Self {
        return self * 180 / .pi
    }
}
