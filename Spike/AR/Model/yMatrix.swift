//
//  yMatrix.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-11-11.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import Foundation
import CoreData
import GLKit.GLKMatrix4
import SceneKit

class yMatrix {
    
    //    column 0  column 1  column 2  column 3
    //        cosθ      0       sinθ      0    
    //         0        1         0       0    
    //       −sinθ      0       cosθ      0    
    //         0        0         0       1    
    
    static func getTranslationMatrix(_ matrix: simd_float4x4, _ translation : vector_float4) -> simd_float4x4 {
        var matrix = matrix
        matrix.columns.3 = translation
        return matrix
    }
    
    
    static func transformMatrix(_ matrix: simd_float4x4, _ originLocation: CLLocation, _ pinLocation: CLLocation) -> simd_float4x4 {
        let coordinate = CLLocationCoordinate2D(latitude: 49.24297, longitude: -123.118729)
        let pinLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        // My current location
        let myLocation = CLLocation()
        let distance = Float(myLocation.distance(from: pinLocation))
        
        // Get a rotation of pin aroun Y axis
        let bearing = myLocation.coordinate.calculateBearing(to: coordinate)
        let rotationMatrix = rotateAroundY(matrix_identity_float4x4, Float(bearing))
        
        // Get a translation of pin
        let position = vector_float4(0.0, 0.0, -distance, 0.0)
        let translationMatrix = getTranslationMatrix(matrix_identity_float4x4, position)
        
        let transformMatrix = simd_mul(rotationMatrix, translationMatrix)
        return simd_mul(matrix, transformMatrix)
    }
    
    static func rotateAroundY(_ matrix: simd_float4x4, _ degrees: Float) -> simd_float4x4 {
        var matrix = matrix
        matrix.columns.0.x = cos(degrees)
        matrix.columns.0.z = -sin(degrees)
        matrix.columns.2.x = sin(degrees)
        matrix.columns.2.z = cos(degrees)
        return matrix.inverse
    }
}
