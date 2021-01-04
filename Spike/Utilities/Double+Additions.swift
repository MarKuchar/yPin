//
//  Double .swift
//  Spike
//
//  Created by Martin Kuchar on 2020-11-11.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import Foundation

extension Double {
    func toRadians() -> Double {
        return self * .pi / 180.0
    }
    
    func toDegrees() -> Double {
        return self * 180.0 / .pi
    }
}
