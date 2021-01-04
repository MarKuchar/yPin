//
//  yPin.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-11-11.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import Foundation


import SceneKit
import ARKit
import CoreLocation

class yNode: SCNNode {
    
    let title: String
    
    var anchor: ARAnchor? {
        didSet {
            guard let transform = anchor?.transform else { return }
            self.position = positionFromTransform(transform)
        }
    }
    
    var location: CLLocation!
    
    init(title: String, location: CLLocation) {
        self.title = title
        super.init()
        // Constraint that orients a node to always point toward the current camera
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        constraints = [billboardConstraint]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // When we update our position we take the anchor's matrix to transform 
    func positionFromTransform(_ transform: matrix_float4x4) -> SCNVector3 {
        
        //    column 0  column 1  column 2  column 3
        //         1        0         0       X    
        //         0        1         0       Y    
        //         0        0         1       Z    
        //         0        0         0       1    
        
        return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
    
    
    func rotateNode(_ angleInRadians: Float, _ transform: SCNMatrix4) -> SCNMatrix4 {
        let rotation = SCNMatrix4MakeRotation(angleInRadians, 0, 1, 0)
        return SCNMatrix4Mult(transform, rotation)
    }
    
    static func translateNode (location: CLLocation, userLocation: CLLocation) -> ARAnchor {
        let locationTransform = yMatrix.transformMatrix(matrix_identity_float4x4, userLocation, location)
        return ARAnchor(transform: locationTransform)
    }
}
