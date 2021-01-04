//
//  yWarningLabel.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-12-09.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit

class yWarningLabel: UILabel {

    required init() {
        super.init(frame: .zero)
        
        self.text = ""
        self.textColor = .red
        self.textAlignment = .center
        self.font = UIFont(name: "Optima Regular", size: 20)
        self.numberOfLines = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
