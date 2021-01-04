//
//  yTemplateButtonWebsite.swift
//  Spike
//
//  Created by Cayo on 2020-12-22.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit

@IBDesignable
class yTemplateButtonWebsite: UIButton {

    weak var templateVC: yTemplateViewController?
    weak var delegate: yTemplateButtonWebsiteDelegate?
    
    var editable: Bool = false {
        didSet {
            updateComponent()
        }
    }
    
    var url: URL?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    let popupInput = UIAction.init(title: "popupInput") { action in
        guard let btn = action.sender as? yTemplateButtonWebsite else { return }
        
        let alert = UIAlertController.init(title: "Input", message: "Enter website address", preferredStyle: .alert)
        
        alert.addTextField { (tf) in
            tf.placeholder = "Enter here http://example.com"
            tf.addAction(.init(handler: { action in
                if let str = tf.text, str.count > 5 {
                    alert.actions.first?.isEnabled = str.validURL
                } else {
                    alert.actions.first?.isEnabled = false
                }
            }), for: .editingChanged)
        }
        
        alert.addAction(.init(title: "OK", style: .default, handler: { (a) in
            if let path = alert.textFields?[0].contents, let url = URL.init(string: path) {
                btn.url = url
                btn.delegate?.updated(newValue: url, on: btn)
            }
        }))
        
        alert.addAction(.init(title: "Cancel", style: .cancel))
        
        alert.actions.first?.isEnabled = false
        
        btn.templateVC?.present(alert, animated: true)
    }
    
    let openWebsite = UIAction.init(title: "openWebsite") { action in
        if let btn = action.sender as? yTemplateButtonWebsite,
           let url = btn.url {
            btn.delegate?.openWebsite(withURL: url)
        }
    }
    
    func updateComponent() {
        if self.editable {
            self.removeAction(self.openWebsite, for: .touchUpInside)
            self.addAction(self.popupInput, for: .touchUpInside)
        } else {
            self.removeAction(self.popupInput, for: .touchUpInside)
            self.addAction(self.openWebsite, for: .touchUpInside)
        }
    }
    
    func setup( withTemplateVC vc: yTemplateViewController, andDelegate delegate: yTemplateButtonWebsiteDelegate, editable: Bool, andInitialValue initialValue: URL? = nil) {
        self.templateVC = vc
        self.delegate = delegate
        self.url = initialValue
        self.editable = editable
    }
    
}

protocol yTemplateButtonWebsiteDelegate: class {
    func updated(newValue: URL?, on button: yTemplateButtonWebsite)
    
    func openWebsite(withURL url: URL)
    
}
