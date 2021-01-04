//
//  UINavigationController+Animation.swift
//  Spike
//
//  Created by Cornerstone on 2020-11-09.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    func pushViewControllerFromBottom(_ viewController: UIViewController, animated: Bool = true) {
        let transation = CATransition.init()
        transation.duration = 0.5
        transation.timingFunction = .init(name: .easeInEaseOut)
        transation.type = .push
        transation.subtype = .fromTop
        self.view.layer.add(transation, forKey: kCATransition)
        self.pushViewController(viewController, animated: animated)
    }
    
    func pushViewControllerFromTop(_ viewController: UIViewController, animated: Bool = true) {
        let transation = CATransition.init()
        transation.duration = 0.5
        transation.timingFunction = .init(name: .easeInEaseOut)
        transation.type = .push
        transation.subtype = .fromBottom
        self.view.layer.add(transation, forKey: kCATransition)
        self.pushViewController(viewController, animated: animated)
    }
    
    func popViewControllerFromTop(animated: Bool = true) {
        let transation = CATransition.init()
        transation.duration = 0.5
        transation.timingFunction = .init(name: .easeInEaseOut)
        transation.type = .push
        transation.subtype = .fromBottom
        self.view.layer.add(transation, forKey: kCATransition)
        self.popViewController(animated: animated)
    }
    
    func popToRootViewControllerFromTop(animated: Bool = true) {
        let transation = CATransition.init()
        transation.duration = 0.5
        transation.timingFunction = .init(name: .easeInEaseOut)
        transation.type = .push
        transation.subtype = .fromBottom
        self.view.layer.add(transation, forKey: kCATransition)
        self.popToRootViewController(animated: animated)
    }
    
}
