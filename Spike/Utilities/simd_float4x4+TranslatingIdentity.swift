//
//  simd_float4x4+TranslatingIdentity.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-11-11.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import Foundation
import SceneKit

extension simd_float4x4 {
    
    static func translatingIdentity(x: Float, y: Float, z: Float) -> simd_float4x4 {
        var result = matrix_identity_float4x4
        result.columns.3.x = x
        result.columns.3.y = y
        result.columns.3.z = z
        return result
    }
}
