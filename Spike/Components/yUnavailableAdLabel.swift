//
//  yUnavailableAd.swift
//  Spike
//
//  Created by Martin Kuchar on 2021-01-03.
//  Copyright © 2021 Martin Kuchar. All rights reserved.
//

import UIKit

class yUnavailableAdLabel: UILabel {

    required init() {
        super.init(frame: .zero)
        
        self.text = ""
        self.textColor = .blue
        self.textAlignment = .center
        self.font = UIFont(name: "Optima Regular", size: 25)
        self.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.numberOfLines = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
