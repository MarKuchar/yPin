//
//  String.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-11-09.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func image() -> UIImage? {
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: CGPoint(), size: size)
        UIRectFill(CGRect(origin: CGPoint(), size: size))
        (self as NSString).draw(in: rect, withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 90)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    var validURL: Bool {
            get {
                guard let url = URL.init(string: self) else { return false }
                let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
                let predicate = NSPredicate(format: "SELF MATCHES %@", argumentArray: [regEx])
                return predicate.evaluate(with: self) && UIApplication.shared.canOpenURL(url)
            }
        }
}
