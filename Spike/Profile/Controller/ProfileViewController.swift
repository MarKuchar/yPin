//
//  ProfileViewController.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-10-20.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit
import Firebase

protocol UpdateInfo: class {
    func updateData()
}

class ProfileViewController: UIViewController, UINavigationControllerDelegate {
    
    var user: User! {
        didSet {
            userName.text = user.displayName
            userEmail.text = user.email
            setupImageView()
        }
    }
    
    private var authUser = Auth.auth().currentUser!
    private lazy var userDocRef = Firestore.firestore().collection("users").document(authUser.uid)
    weak var delegate: UpdateInfo!
    
    private lazy var userName: UILabel = {
        let lb = UILabel()
        lb.font = UIFont(name: "Optima Regular", size: 35)
        lb.textColor = .black
        lb.textAlignment = .center
        return lb
    }()
    
    private lazy var userEmail: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.font = UIFont(name: "Optima Regular", size: 20)
        lb.textColor = .black
        return lb
    }()
    
    let signOutBtn: yButton = {
        let btn = yButton(text: "Sign Out")
        btn.setTitleColor(.systemRed, for: .normal)
        btn.alpha = 1
        return btn
    }()
    
    private let userImage: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
        observeUser()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackground()
        
        setupView()
        signOutBtn.addTarget(self, action: #selector(signOut(_:)), for: .touchUpInside)
    }

    @objc func signOut(_ btn: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("User was signed out!")
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @objc func setProfileInfo(_ btn: UIButton) {
        let setProfileInfoVC = ProfileSettingsViewController()
        setProfileInfoVC.user = user
        setProfileInfoVC.userImage.image = userImage.image
        navigationController?.pushViewController(setProfileInfoVC, animated: true)
    }
    
    private func observeUser() {
        userDocRef.addSnapshotListener { documentSnapshot, error in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            if let snap = documentSnapshot {
                let data = try? snap.data(as: User.self)
                self.user = data
                return
            }
        }
    }
    
    private func setBackground() {
        let background = UIImage(named: "CityProfile")
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
    
    private func setupNavBar() {
        let imageV = UIImageView(image: UIImage(named: "Settings"))
        imageV.constraintWidth(equalToConstant: 40)
        imageV.constraintHeight(equalToConstant: 40)        
        let barBtn = UIBarButtonItem(customView: imageV)
        barBtn.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setProfileInfo(_:))))
        self.navigationItem.rightBarButtonItem = barBtn
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor = .black
    }
    
    private func setupView() {
        
        let vStack1 = VerticalStackView(
        arrangedSubviews: [userName, userEmail], spacing: 10, alignment: .center)
        view.addSubview(vStack1)
        view.addSubview(userImage)
        view.addSubview(signOutBtn)
        let height = view.frame.height
        let width = view.frame.width
        
        userImage.constraintHeight(equalToConstant: width * 0.6)
        userImage.constraintWidth(equalToConstant: width * 0.6)
    
        NSLayoutConstraint.activate([
            vStack1.topAnchor.constraint(equalTo: view.topAnchor, constant: height / 10),
            vStack1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userImage.topAnchor.constraint(equalTo: vStack1.bottomAnchor, constant: height / 8),
            userImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signOutBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signOutBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -height / 12),
            signOutBtn.widthAnchor.constraint(equalToConstant: width * 0.9)
        ])
    }
    
    private func setupImageView() {
        if let photoURL = URL(string: user.photoURL) {
            RepositoryFactory.createUserRepository().downloadImage(from: photoURL) { image in
                if let image = image {
                    DispatchQueue.main.async {
                        self.userImage.layer.cornerRadius = (self.userImage.frame.width) / 2
                        self.userImage.layer.borderWidth = 2.0
                        self.userImage.layer.borderColor = CGColor(red: 1, green: 0, blue: 0, alpha: 1)
                        self.userImage.clipsToBounds = true
                        self.userImage.image = image
                    }
                }
            }
        } else {
            self.userImage.image = UIImage(named: "UserIcon")!
        }
    }
}
