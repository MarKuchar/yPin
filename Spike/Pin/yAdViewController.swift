//
//  AdViewController.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-11-12.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit

class yAdViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.148, green: 0.282, blue: 0.312, alpha: 1)
        
        let BackgroundImage = UIImage(named: "Grid")?.cgImage
        let Background = CALayer()
        Background.contents = BackgroundImage
        Background.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0))
        Background.bounds = view.bounds
        Background.position = view.center
        view.layer.addSublayer(Background)
    }
}
