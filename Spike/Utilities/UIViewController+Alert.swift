//
//  UIViewController+Alert.swift
//  Spike
//
//  Created by Cornerstone on 2020-11-04.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlertConfirmation(withTitle title: String, andMessage messsage: String, completion: (() -> Void)? = nil) {
        let confirmAlert = UIAlertController.init(title: title, message: messsage, preferredStyle: .alert)
        
        confirmAlert.addAction(.init(title: "Ok", style: .default) { (action) in
            if let completion = completion {
                completion()
            }
        })
        
        self.present(confirmAlert, animated: true)
    }
}
