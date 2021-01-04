//
//  ViewController.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-10-08.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    let signOutBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Sign Out", for: .normal)
        return btn
    }()
    
    var signInGoogleBtn = GIDSignInButton()
    
    
    var signInFbBtn = FBLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let vStack = VerticalStackView(arrangedSubviews: [signInGoogleBtn, signInFbBtn, signOutBtn,])
        view.addSubview(vStack)
        vStack.centerXYin(view)
        
        signInGoogleBtn.constraintWidth(equalToConstant: view.frame.width * 0.6)
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        if GIDSignIn.sharedInstance()?.currentUser != nil {
            signOutBtn.isEnabled = true
        } else {
            GIDSignIn.sharedInstance()?.signIn()
            signOutBtn.isEnabled = false
        }
        
        // facebok check
        if let token = AccessToken.current,
            !token.isExpired {
            // User is logged in, do work such as go to next view controller.
        }
        
        // check permission
        //        loginButton.permissions = ["public_profile", "email"]
        
        signInFbBtn.delegate = self
    }
}

extension LoginViewController: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        if let current = AccessToken.current {
            let credential = FacebookAuthProvider.credential(withAccessToken: current.tokenString)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                //handle sign-in errors
                if let error = error {
                    if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                        print("The user has not signed in before or they have since signed out.")
                    } else {
                        print("error signing into FB \(error.localizedDescription)")
                    }
                    return
                }
            }
        } else {
            print("Unsuccessfull")
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }
    
    @objc
    private func googleLogin(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.signIn()
    }
}


