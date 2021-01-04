//
//  yTemplateLabel.swift
//  Spike
//
//  Created by Cornerstone on 2020-11-17.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit

@IBDesignable
class yTemplateLabel: UILabel {
    
    weak var templateVC: yTemplateViewController?
    weak var delegate: yTemplateLabelDelegate?
    
    var defaultText = " --- "
    
    var editable: Bool = false {
        didSet {
            updateComponent()
        }
    }
    
    var flag = true
    
    override var text: String? {
        didSet {
            guard flag else {
                flag = !flag
                return
            }
            flag = !flag
            text = text ?? defaultText
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.defaultText = self.text ?? self.defaultText
        setupGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.defaultText = self.text ?? self.defaultText
        setupGestureRecognizer()
    }

    func updateComponent() {
        if self.editable {
            self.layer.cornerRadius = UIConstants.TemplateComponent.editableCornerRadius
            self.layer.backgroundColor = UIConstants.TemplateComponent.editableColor
            self.isUserInteractionEnabled = true
        } else {
            self.backgroundColor = .none
            self.layer.cornerRadius = .zero
            self.isUserInteractionEnabled = false
        }
    }
    
    func setupGestureRecognizer() {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapTemplateLabel))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }
    
    func setup(
        withTemplateVC vc: yTemplateViewController,
        andDelegate delegate: yTemplateLabelDelegate,
        editable: Bool,
        initialValue: String?) {
        self.templateVC = vc
        self.delegate = delegate
        self.editable = editable
        self.text = initialValue ?? self.text
    }
    
    @objc func tapTemplateLabel() {
        
        let alert = UIAlertController.init(title: "Input", message: "Enter Text Input", preferredStyle: .alert)
        
        alert.addTextField { (tf) in
            tf.placeholder = "Enter here"
        }
        
        alert.addAction(.init(title: "OK", style: .default, handler: { (a) in
            let newValue = alert.textFields![0].contents
            self.text = newValue
            self.delegate?.updated(newValue: newValue, on: self)
        }))
        
        alert.addAction(.init(title: "Cancel", style: .cancel))
        
        self.templateVC?.present(alert, animated: true)
    }
    
}

protocol yTemplateLabelDelegate: class {
    func updated(newValue: String?, on label: yTemplateLabel)
}
