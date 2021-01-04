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
import FirebaseUI
import GoogleSignIn
import FBSDKLoginKit

class SignInViewController: UIFormViewController {
    
    lazy var slideMenuHeight: CGFloat = 300
    var frame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    lazy var imageWidth = self.view.frame.width
    lazy var imageHeight = imageWidth / 1.4362
    
    var appTitleImage: UIImageView = {
        let appleIV = UIImageView()
        appleIV.image = UIImage(named: "AppTitle.png")
        appleIV.contentMode = .scaleAspectFit
        return appleIV
    }()
    
    let scrollView: UIScrollView = {
        let sV = UIScrollView()
        sV.translatesAutoresizingMaskIntoConstraints = false
        sV.showsVerticalScrollIndicator = false
        sV.showsHorizontalScrollIndicator = false
        sV.isPagingEnabled = true
        return sV
    }()
    
    let pageControl: UIPageControl = {
        let pC = UIPageControl()
        pC.numberOfPages = 3
        pC.currentPage = 0
        pC.tintColor = .black
        pC.currentPageIndicatorTintColor = .red
        pC.translatesAutoresizingMaskIntoConstraints = false
        return pC
    }()
    
    var unfocusedView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        return view
    }()
    
    var slideMenu: UIView = {
        var view = UIView()
        view.applyBackground(withLayer: .backgroundGrid, andColor: UIConstants.backgroundColor)
        view.alpha = 0.9
        view.layer.cornerRadius = 10
        return view
    }()
    
    let mainSignInBtn: yButton = {
        let btn = yButton(text: "Let's Explore")
        btn.alpha = 0.7
        return btn
    }()
    
    let signUpBtn: yButton = {
        let btn = yButton(text: "Sign Up")
        return btn
    }()
    
    let signInBtn: yButton = {
        let btn = yButton(text: "Sign In")
        return btn
    }()
    
    let googleBtn: ySignInButton = {
        let btn = ySignInButton(text: "Sign In with Google", iconName: "GoogleIcon")
        btn.constraintHeight(equalToConstant: 40)
        return btn
    }()
    
    let appleBtn: ySignInButton = {
        let btn = ySignInButton(text: "Sign In with Apple", iconName: "AppleIcon")
        btn.constraintHeight(equalToConstant: 40)
        return btn
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackground()
        scrollView.delegate = self
        setupView()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        signUpBtn.addTarget(self, action: #selector(registerUser(_:)), for: .touchUpInside)
        signInBtn.addTarget(self, action: #selector(signInWithPassword(_:)), for: .touchUpInside)
        googleBtn.addTarget(self, action: #selector(signInWithGoogle(_:)), for: .touchUpInside)
        appleBtn.addTarget(self, action: #selector(signInWithApple(_:)), for: .touchUpInside)
        mainSignInBtn.addTarget(self, action: #selector(slideUpMenu(_:)), for: .touchUpInside)
        
    }
    
    @objc func slideUpMenu(_ btn: UIButton) {
        mainSignInBtn.isHidden = true
        unfocusedView.frame = self.view.frame
        unfocusedView.alpha = 0
        view.addSubview(unfocusedView)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(slideDownMenu(_:)))
        unfocusedView.addGestureRecognizer(gestureRecognizer)
        
        let screen = view.bounds
        slideMenu.frame = CGRect(x: 0, y: screen.height, width: screen.width, height: slideMenuHeight)
        view.addSubview(slideMenu)
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            options: .curveEaseInOut, animations: {
                self.unfocusedView.alpha = 0.5
                self.slideMenu.frame = CGRect(x: 0, y: screen.height - self.slideMenuHeight, width: screen.width, height: self.slideMenuHeight)
            }, completion: nil)
    }
    
    @objc func slideDownMenu(_ btn: UIButton) {
        mainSignInBtn.isHidden = false
        let screen = view.bounds
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            options: .curveEaseInOut, animations: {
                self.unfocusedView.alpha = 0
                self.slideMenu.frame = CGRect(x: 0, y: screen.height, width: screen.width, height: self.slideMenuHeight)
            }, completion: nil)
        
    }
    
    @objc func registerUser(_ btn: UIButton) {
        let registrationVC = SignUpViewController()
        navigationController?.present(registrationVC, animated: true, completion: nil)
    }
    
    @objc func signInWithPassword(_ btn: UIButton) {
        let navVC = UINavigationController(rootViewController: PSWSignInViewController())
        navigationController?.present(navVC.translucentNavController(), animated: true, completion: nil)
    }
    
    @objc func signInWithGoogle(_ btn: UIButton) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @objc func signInWithApple(_ btn: UIButton) {
        if let authUI = FUIAuth.defaultAuthUI() {
            authUI.providers = [FUIOAuth.appleAuthProvider()]
            authUI.delegate = self
            
            let authVC = authUI.authViewController()
            self.present(authVC, animated: true, completion: nil)
        }
    }
    
    func setBackground(){
        let background = UIImage(named: "City")
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
    
    private func setupView() {
        let hStack = HorizontalStackView(
            arrangedSubviews: [signUpBtn, signInBtn],
            spacing: 5,
            distribution: .fillEqually)
        
        let vStack2 = VerticalStackView(
            arrangedSubviews: [appleBtn, googleBtn],
            spacing: 15,
            distribution: .equalSpacing)
        
        let vStack3 = VerticalStackView(
            arrangedSubviews: [vStack2, hStack],
            spacing: 30,
            distribution: .equalSpacing)
        
        view.addSubview(appTitleImage)
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        view.addSubview(mainSignInBtn)
        
        appTitleImage.constraintHeight(equalToConstant: imageWidth * 0.3)
        appTitleImage.constraintWidth(equalToConstant: imageWidth * 0.3)
        let screenHeight = view.frame.height
        
        slideMenu.addSubview(vStack3)
        vStack3.centerXYin(slideMenu)
        
        setupScrollView()
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -20),
            scrollView.heightAnchor.constraint(equalToConstant: imageHeight),
            pageControl.bottomAnchor.constraint(equalTo: mainSignInBtn.topAnchor, constant: -screenHeight / 12),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            vStack3.widthAnchor.constraint(equalTo: slideMenu.widthAnchor, multiplier: 0.9),
            mainSignInBtn.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            appTitleImage.topAnchor.constraint(equalTo: view.topAnchor, constant: screenHeight / 10),
            appTitleImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainSignInBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainSignInBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -screenHeight / 10)
        ])
    }
    
    private func setupScrollView() {
        scrollView.contentSize = CGSize(width: imageWidth * 3, height: imageHeight)
        
        let hStack = HorizontalStackView(arrangedSubviews: [])
        scrollView.addSubview(hStack)
        for i in 1...3 {
            let imageToPresent = UIImage(named: "Presentation\(i)")
            let imageView = UIImageView(image: imageToPresent)
            imageView.contentMode = .scaleAspectFit
            
            imageView.constraintWidth(equalToConstant: imageWidth)
            imageView.constraintHeight(equalToConstant: imageHeight)
            hStack.addArrangedSubview(imageView)
        }
    }
}

// MARK: - Confirm to GIDSignInDelegate

extension SignInViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // handle sign-in errors
        // user.authentication.refreshToken
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("error signing into Google \(error.localizedDescription)")
            }
            return
        }
        
        // Get credential object using Google ID token and Google access token
        guard let authentication = user.authentication else { return }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        // Authenticate with Firebase using the credential object
        Auth.auth().signIn(with: credential) { (authResult, error) in
            //handle sign-in errors
            if let error = error {
                if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                    print("The user has not signed in before or they have since signed out.")
                } else {
                    print("error signing into Google \(error.localizedDescription)")
                }
                return
            }
            
            // Get credential object using Google ID token and Google access token
            guard let authentication = user.authentication else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                           accessToken: authentication.accessToken)
            
            // Authenticate with Firebase using the credential object
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print("authentication error \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Confirm to Firebase auth delegate

extension SignInViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let user = authDataResult?.user {
            print("\(user.displayName ?? "") was signed in")
        }
    }
}

extension SignInViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
}
