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
        var image = UIImage(named: "SignUp")!
        SignUpView.image = image
        SignUpView.constraintWidth(equalToConstant: 200)
        SignUpView.constraintHeight(equalToConstant: 100)
        return SignUpView
    }()
    
    private lazy var userName: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: "User name",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.176, green: 0.278, blue: 0.314, alpha: 1)])
        textField.backgroundColor = UIColor(red: 0.212, green: 0.416, blue: 0.463, alpha: 1)
        textField.font = UIFont(name: "Optima Regular", size: 20)
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.textColor = .white
        textField.delegate = self
        return textField
    }()
    
    private lazy var emailAddress: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.176, green: 0.278, blue: 0.314, alpha: 1)])
        textField.backgroundColor = UIColor(red: 0.212, green: 0.416, blue: 0.463, alpha: 1)
        textField.font = UIFont(name: "Optima Regular", size: 20)
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.textColor = .white
        textField.delegate = self
        return textField
    }()
    
    private lazy var password: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.176, green: 0.278, blue: 0.314, alpha: 1)])
        textField.backgroundColor = UIColor(red: 0.212, green: 0.416, blue: 0.463, alpha: 1)
        textField.font = UIFont(name: "Optima Regular", size: 20)
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.textColor = .white
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
    
    private let warningLabel: UILabel  = {
        let lb = UILabel()
        lb.text = ""
        lb.textColor = .red
        lb.textAlignment = .center
        return lb
    }()
    
    let signInBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Sign In", for: .normal)
        btn.tintColor = .white
        btn.titleLabel?.font = UIFont(name: "Optima Regular", size: 25)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 0.314, green: 0.492, blue: 0.554, alpha: 1)
        btn.layer.cornerRadius = 10
        btn.contentEdgeInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.applyBackground(withLayer: .backgroundGrid, andColor: UIConstants.backgroundColor)
        
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
        vStack.centerXYin(view)
        vStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        vStack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        vStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100).isActive = true
        SignInImage.bottomAnchor.constraint(equalTo: vStack.topAnchor, constant: -100).isActive = true
        SignInImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        password.widthAnchor.constraint(equalTo: vStack.widthAnchor).isActive = true
        
        signInBtn.addTarget(self, action: #selector(signInWithPassword(_:)), for: .touchUpInside)
        forgottenPSWBtn.addTarget(self, action: #selector(resetPSW(_:)), for: .touchUpInside)
        
    }
    
    private func signInUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            if let error = error {
                print(error.localizedDescription)
                strongSelf.warningLabel.text = "There is no user corresponding to this information"
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
            warningLabel.text = "Fields must be filled"
            warningLabel.font = UIFont(name: "Optima Regular", size: 25)
        }
    }
    
    @objc func resetPSW(_ btn: UIButton) {
        let resetPswVC = ResetPSWViewController()
        navigationController?.present(resetPswVC, animated: true, completion: nil)
    }
}
