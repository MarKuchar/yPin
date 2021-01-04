//
//  Contants.swift
//  Spike
//
//  Created by Cornerstone on 2020-11-04.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit

enum UIConstants {
    static let padding = CGFloat.init(16)
    static let backgroundColor = UIColor(red: 53/255, green: 168/255, blue: 222/255, alpha: 1)
    static let screenSize = UIScreen.main.bounds
    
    enum StackView {
        static let spacing = CGFloat.init(16)
    }
    enum CollecionView {
        static let lineSpace = CGFloat.init(16.0)
        static let viewPadding = UIEdgeInsets.init(top: 60.0, left: 16.0, bottom: .zero, right: 16.0)
        static let cellCornerRadius = CGFloat.init(20.0)
    }
    
    enum Button {
        static let buttonIconSize = CGSize.init(width: 44, height: 44)
        static let buttonSize = CGSize.init(width: 44, height: 44)
        static let cornerRadius = CGFloat.init(20.0)
    }
    
    enum TemplateComponent {
        static let editableCornerRadius = CGFloat.init(10.0)
        static let editableColor = UIColor(red: 0.743, green: 0.772, blue: 0.779, alpha: 0.44).cgColor
    }
}

extension CGSize {

    public static var buttonIconSize: CGSize { get { return UIConstants.Button.buttonIconSize } }

}

extension UIColor {
    public static var ybackgroundColor: UIColor { get { return UIConstants.backgroundColor } }
}
