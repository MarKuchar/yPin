//
//  yTextField.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-12-09.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit

class yTextField: UITextField {
    
    let placeholderText: String
    
    required init(text: String) {
        
        self.placeholderText = text
        
        super.init(frame: .zero)
        
        self.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.314, green: 0.492, blue: 0.554, alpha: 1)])
        self.backgroundColor = UIColor(red: 15/255, green: 143/255, blue: 212/255, alpha: 0.3)
        self.font = UIFont(name: "Optima Regular", size: 20)
        self.borderStyle = .roundedRect
        self.textAlignment = .center
        self.textColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
