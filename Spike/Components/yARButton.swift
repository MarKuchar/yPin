//
//  yARButton.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-12-10.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit

class yARButton: UIButton {
    let title: String!
    
    required init(title: String) {
        self.title = title
        super.init(frame: .zero)
        
        self.setImage(UIImage(named: title), for: .normal)
        self.constraintHeight(equalToConstant: 44)
        self.constraintWidth(equalToConstant: 44)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.startAnimatingPressActions()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

