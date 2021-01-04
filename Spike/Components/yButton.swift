//
//  yButton.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-12-09.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit

class yButton: UIButton {
    
    let text: String
    
    required init(text: String) {
        
        self.text = text
        
        super.init(frame: .zero)
        
        self.setTitle(text, for: .normal)
        self.tintColor = .white
        self.titleLabel?.font = UIFont(name: "Optima Regular", size: 25)
        self.setTitleColor(.white, for: .normal)
        self.backgroundColor = UIColor(red: 15/255, green: 143/255, blue: 212/255, alpha: 0.3)
        self.contentEdgeInsets = UIEdgeInsets(top: 4.0, left: 8.0, bottom: 4.0, right: 8.0)
        
        self.layer.cornerRadius = 3
        self.layer.shadowColor = UIColor(red: 0.176, green: 0.278, blue: 0.314, alpha: 1).cgColor
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 10
        self.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        self.layer.borderWidth = 0.05
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.startAnimatingPressActions()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
