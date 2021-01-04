//
//  UINavigationController+NavigationBar.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-12-05.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit

extension UINavigationController {
    func translucentNavController() -> Self {
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.navigationItem.backBarButtonItem?.tintColor = .black
        return self
    }
}
