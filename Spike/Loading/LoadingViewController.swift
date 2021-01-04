//
//  LoadingViewController.swift
//  Spike
//
//  Created by Cornerstone on 2020-10-08.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoadingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.208, green: 0.42, blue: 0.467, alpha: 1)    
        let BackgroundImage = UIImage(named: "Starting")?.cgImage
        let Background = CALayer()

        Background.contents = BackgroundImage
        Background.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0))
        Background.position = view.center
        view.layer.addSublayer(Background)
        
        
    }
}

// TODO:
// To remeber either the app was launch befor
// https://medium.com/anysuggestion/detecting-the-first-launch-of-the-ios-application-the-wrong-and-the-right-way-78b0605bd8b2

final class FirstLaunch {
    
    let wasLaunchedBefore: Bool
    var isFirstLaunch: Bool {
        return !wasLaunchedBefore
    }
    
    init(getWasLaunchedBefore: () -> Bool,
         setWasLaunchedBefore: (Bool) -> ()) {
        let wasLaunchedBefore = getWasLaunchedBefore()
        self.wasLaunchedBefore = wasLaunchedBefore
        if !wasLaunchedBefore {
            setWasLaunchedBefore(true)
        }
    }
    
    convenience init(userDefaults: UserDefaults, key: String) {
        self.init(getWasLaunchedBefore: { userDefaults.bool(forKey: key) },
                  setWasLaunchedBefore: { userDefaults.set($0, forKey: key) })
    }
}


