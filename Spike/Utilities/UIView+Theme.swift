//
//  UIView+Theme.swift
//  Spike
//
//  Created by Cornerstone on 2020-11-04.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit

extension UIView {
    func applyBackground(withLayer layer: CALayer, andColor color: UIColor = UIConstants.backgroundColor) {
        self.backgroundColor = color
        layer.bounds = self.bounds
        layer.position = self.center
        self.layer.addSublayer(layer)
    }
}


extension CALayer {

    public static var backgroundGrid: CALayer {
        get {
            let bg = CALayer()
            bg.contents = UIImage(named: "Grid")?.cgImage
            bg.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0))
            return bg
        }
        
    }

}
