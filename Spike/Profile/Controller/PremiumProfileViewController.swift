//
//  ChangeNameVC.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-12-23.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit
import Firebase

class PremiumProfileViewController: UIFormViewController {
    
    private let authUser = Auth.auth().currentUser!
    var user: User!
    lazy var userDocRef = Firestore.firestore().collection("users").document(authUser.uid)
    private lazy var width = view.bounds.width
    var delegate: ChangePremium!
    
    lazy var currentState = user.premium ? "Premium" : "not Premium"
    
    lazy var premiumApplicationDescription: UILabel = {
        let lb = UILabel()
        lb.text =
            """
            Dear \(user.displayName).\n\n
            Your profile is currently \(currentState), in order to change the state
            of your profile please apply here.
            Your profile will be upgraded immediately and we will reach out to you at your email address:
            \(user.email) with the additional questions as soon as we can.\n
            Thank you for being an active user!
            """
        lb.numberOfLines = 0
        lb.textAlignment = .center
        lb.font = UIFont(name: "Optima Regular", size: 20)
        return lb
    }()
    
    private let warningLabel = yWarningLabel()
    
    lazy var applyForPremiumBtn: yButton = {
        let btn = yButton(text: "\(user.premium ? "DEACTIVATE" : "ACTIVATE") PREMIUM")
        return btn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ybackgroundColor
        applyForPremiumBtn.addTarget(self, action: #selector(applyForPremium(_:)), for: .touchUpInside)
        setupView()
    }
    
    @objc func applyForPremium(_ btn: UIButton) {
        let newState = !user.premium
        userDocRef.updateData(["premium": newState]) { error in
            if let error = error {
                self.warningLabel.textColor = .red
                self.warningLabel.text = error.localizedDescription
                return
            }
            self.delegate.changePremium(toActive: newState)
            self.warningLabel.textColor = .green
            self.warningLabel.text = "Your profile will succesfully upgraded, we will come to you soon."
        }
    }
    
    private func setupView() {
        let vStack = VerticalStackView(
            arrangedSubviews: [premiumApplicationDescription, warningLabel, applyForPremiumBtn], spacing: 30, alignment: .center)
        
        view.addSubview(vStack)
        vStack.centerXYin(view)
        
        NSLayoutConstraint.activate([
            applyForPremiumBtn.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            vStack.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)
        ])
    }
}
