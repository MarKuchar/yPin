//
//  RegisterViewController.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-10-13.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class PSWSignInViewController: UIFormViewController {
    
    private let SignInImage: UIImageView = {
        let SignUpView = UIImageView()
        var image = UIImage(named: "SignIn")!
        SignUpView.image = image
        SignUpView.constraintWidth(equalToConstant: 250)
        SignUpView.constraintHeight(equalToConstant: 150)
        return SignUpView
    }()
    
    private lazy var userName: yTextField = {
        let textField = yTextField(text: "User name")
        textField.delegate = self
        return textField
    }()
    
    private lazy var emailAddress: yTextField = {
        let textField = yTextField(text: "Email Address")
        textField.delegate = self
        return textField
    }()
    
    private lazy var password: yTextField = {
        let textField = yTextField(text: "Password")
        textField.isSecureTextEntry = true
        textField.delegate = self
        return textField
    }()
    
    let forgottenPSWBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Forgot password?", for: .normal)
        btn.tintColor = .white
        btn.titleLabel?.font = UIFont(name: "Optima Regular", size: 18)
        return btn
    }()
    
    let signInBtn: yButton = {
        let btn = yButton(text: "Sign In")
        return btn
    }()
    
    private let warningLabel = yWarningLabel()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ybackgroundColor
        
        signInBtn.addTarget(self, action: #selector(signInWithPassword(_:)), for: .touchUpInside)
        forgottenPSWBtn.addTarget(self, action: #selector(resetPSW(_:)), for: .touchUpInside)
        
        setupView()
    }
    
    private func setupView() {
        view.addSubview(SignInImage)
        let vStack1 = VerticalStackView(
            arrangedSubviews: [password, forgottenPSWBtn],
            spacing: 5,
            alignment: .trailing, distribution: .equalSpacing)
        
        let vStack = VerticalStackView(
            arrangedSubviews: [warningLabel, emailAddress, vStack1, signInBtn],
            spacing: 25,
            distribution: .equalSpacing)
        
        view.addSubview(vStack)
        
        NSLayoutConstraint.activate([
            vStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            vStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            vStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100),
            SignInImage.bottomAnchor.constraint(equalTo: vStack.topAnchor, constant: -100),
            SignInImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            password.widthAnchor.constraint(equalTo: vStack.widthAnchor)
        ])
    }
    
    private func signInUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.warningLabel.text = error.localizedDescription
                return
            }
            if let auth = authResult, let _ = auth.user.displayName {
                
                let inVC = yARViewController()
                strongSelf.navigationController?.present(inVC, animated: true, completion: nil)
            }
        }
    }
    
    @objc func signInWithPassword(_ btn: UIButton) {
        guard let email = emailAddress.text,
              let psw = password.text else {
            return
        }
        if !email.isEmpty && !psw.isEmpty {
            signInUser(email: email, password: psw)
        } else {
            warningLabel.text = "All fields must be filled!"
            warningLabel.font = UIFont(name: "Optima Regular", size: 25)
        }
    }
    
    @objc func resetPSW(_ btn: UIButton) {
        let resetPswVC = ResetPSWViewController()
        navigationController?.present(resetPswVC, animated: true, completion: nil)
    }
}
