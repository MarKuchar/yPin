//
//  ySignInButton.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-12-12.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit

class ySignInButton: UIButton {
    
    let text: String
    let iconName: String
    
    required init(text: String, iconName: String) {
        
        self.text = text
        self.iconName = iconName
        
        super.init(frame: .zero)
        
        self.setTitle(text, for: .normal)
        self.tintColor = .white
        self.titleLabel?.font = UIFont(name: "Optima Regular", size: 25)
        self.setTitleColor(.white, for: .normal)
        self.backgroundColor = UIColor(red: 15/255, green: 143/255, blue: 212/255, alpha: 0.3)
        self.contentEdgeInsets = UIEdgeInsets(top: 4.0, left: 12.0, bottom: 4.0, right: 12.0)
        self.titleEdgeInsets = UIEdgeInsets(top: 0.8, left: 16.0, bottom: 0.8, right: 0.8)
        
        self.layer.cornerRadius = 5
        self.layer.shadowColor = UIColor(red: 0.176, green: 0.278, blue: 0.314, alpha: 1).cgColor
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 10
        self.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        self.layer.borderWidth = 0.05
    
        self.contentHorizontalAlignment = .left
        self.setImage(UIImage(named: iconName), for: .normal)
        self.imageView!.contentMode = .scaleAspectFit
        self.imageEdgeInsets = UIEdgeInsets(top: 0.8, left: 0.8, bottom: 0.8, right: 250)
        
        self.startAnimatingPressActions()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
