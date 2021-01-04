//
//  ResetPSWViewController.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-10-18.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit
import Firebase

class ResetPSWViewController: UIFormViewController {
    
    private lazy var userEmail: yTextField = {
        let textField = yTextField(text: "Enter your email")
        textField.delegate = self
        return textField
    }()
    
    let resetPswBtn: yButton = {
        let btn = yButton(text: "Reset Password")
        return btn
    }()
    
    private var warningLabel = yWarningLabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ybackgroundColor
        
        resetPswBtn.addTarget(self, action: #selector(resetPSW(_:)), for: .touchUpInside)
        setupView()
    }
    
    @objc func resetPSW(_ btn: UIButton) {
        guard let email = userEmail.text else {
            warningLabel.text = "Enter valid email address"
            return
        }
        // Email template can be customised
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                self.warningLabel.textColor = .red
                self.warningLabel.text = error.localizedDescription
                return
            }
            self.warningLabel.textColor = .green
            self.warningLabel.text = "New password was sent to your email."
        }
    }
    
    private func setupView() {
        let vStack = VerticalStackView(
            arrangedSubviews: [warningLabel, userEmail, resetPswBtn], spacing: 30, alignment: .center)
        view.addSubview(vStack)
        vStack.centerXYin(view)
        NSLayoutConstraint.activate([
            resetPswBtn.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            userEmail.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            vStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)
        ])
    }
}
