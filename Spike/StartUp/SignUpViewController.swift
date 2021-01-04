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

class SignUpViewController: UIFormViewController {
    
    var db: Firestore!
    
    private let SignUpImage: UIImageView = {
        let SignUpView = UIImageView()
        var image = UIImage(named: "SignUp")!
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
        textField.delegate = self
        textField.isSecureTextEntry = true
        return textField
    }()
    
    let signUpBtn: yButton = {
        let btn = yButton(text: "Sign Up")
        return btn
    }()
    
    private var warningLabel = yWarningLabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ybackgroundColor
       
        setupView()
        
        signUpBtn.addTarget(self, action: #selector(signUp(_:)), for: .touchUpInside)
        db = Firestore.firestore()
    }
    
    private func setupView() {
        
        let vStack = VerticalStackView(
            arrangedSubviews: [SignUpImage],
            spacing: 25,
            distribution: .equalSpacing)
        
        let vStack1 = VerticalStackView(
            arrangedSubviews: [warningLabel, userName, emailAddress, password, signUpBtn],
            spacing: 25,
            distribution: .equalSpacing)

        view.addSubview(vStack)
        view.addSubview(vStack1)
        NSLayoutConstraint.activate([
            vStack1.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            vStack.bottomAnchor.constraint(equalTo: vStack1.topAnchor, constant: -100),
            vStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            vStack1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            vStack1.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100)
        ])
    }
    
    
    @objc func signUp(_ btn: UIButton) {
        guard let email = emailAddress.text,
        let psw = password.text,  // password has to have 6+ chars
        let username = userName.text else {
            return
        }
        if !email.isEmpty && !psw.isEmpty && !username.isEmpty {
            RepositoryFactory.createUserRepository().createUser(
                with: username, email: email, password: psw, image: nil) { success, error  in
                if let error = error {
                    self.warningLabel.text = error.localizedDescription
                    return
                }
                if success {
                    // Move to the AR Controller
//                    let inVC = MapViewController()
                    let inVC = yARViewController()
                    self.navigationController?.present(inVC, animated: true, completion: nil)
                }
            }
        } else {
            warningLabel.text = "All field must be filled!"
            warningLabel.font = UIFont(name: "Optima Regular", size: 20)
        }
    }
}
