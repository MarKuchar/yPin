//
//  ProfileSettingsViewController.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-10-22.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit
import Firebase

protocol ChangePremium {
    func changePremium(toActive: Bool)
}

class ProfileSettingsViewController: UIFormViewController {
    
    private let authUser = Auth.auth().currentUser!
    var user: User!
    lazy var userDocRef = Firestore.firestore().collection("users").document(authUser.uid)
    
    lazy var data = [user.displayName, user.email, "Change Password", upgradedProfile]
    
    private let profileTV: ySelfSizingTableView = {
        let pTV = ySelfSizingTableView()
        pTV.translatesAutoresizingMaskIntoConstraints = false
        pTV.backgroundColor = UIColor(red: 15/255, green: 143/255, blue: 212/255, alpha: 0.6)
        pTV.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        pTV.layer.cornerRadius = 40
        pTV.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        pTV.register(yTableViewCell.self, forCellReuseIdentifier: "Cell")
        return pTV
    }()
    
    lazy var upgradedProfile = user.premium ? "Your profile is Premium" : "Your profile is not Premium"
    
    private let imageRadius: CGFloat = 220
    private lazy var width = view.bounds.width
    
    private var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        return imagePicker
    }()
    
    let userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 100
        imageView.layer.borderWidth = 2.0
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let editImageBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Edit", for: .normal)
        btn.titleLabel?.font = UIFont(name: "Optima Regular", size: 20)
        btn.setTitleColor(.systemRed, for: .normal)
        return btn
    }()

    private let validationMessage = yWarningLabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIConstants.backgroundColor
        
        setupView()
        setupImagePicker()
        setupNavigation()
        
        profileTV.dataSource = self
        profileTV.delegate = self
    }
    
    
    @objc func openImagePicker(_ sender: Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }

    // MARK:- User input validations
    
    private func tapCell(withText: String) {
        let alert = UIAlertController.init(title: withText, message: "Enter new \(withText)", preferredStyle: .alert)
        
        alert.addTextField { (tf) in
            tf.placeholder = "Enter New Password"
            tf.isSecureTextEntry = withText == "Password"
        }
        if withText == "Password" {
            alert.addTextField { (tf) in
                tf.placeholder = "Re-enter New Password"
                tf.isSecureTextEntry = true
            }
        }
        
        alert.addAction(.init(title: "OK", style: .default, handler: { (a) in
            if let newValue = alert.textFields![0].contents {
                switch withText {
                    case "Email":
                        self.validateEmail(newValue)
                    case "Username":
                        self.validatedUserName(newValue)
                    case "Password":
                        guard let newValue2 = alert.textFields![1].contents else { return }
                        self.validateUserPassword(newValue, newValue2)
                    default:
                        return
                }
            } else {
                self.validationMessage.textColor = .red
                self.validationMessage.text = "Please enter valid information."
            }
        }))
        
        alert.addAction(.init(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    private func validateEmail(_ newEmail: String) {
        // Update Auth user
        authUser.updateEmail(to: newEmail) { (error) in
            if let error = error {
                self.validationMessage.textColor = .red
                self.validationMessage.text = error.localizedDescription
                debugPrint(error.localizedDescription)
            } else {
                // Update Firestore user
                self.userDocRef.updateData(["email": newEmail]) { error in
                    if let error = error {
                        self.validationMessage.textColor = .red
                        self.validationMessage.text = error.localizedDescription
                        debugPrint(error.localizedDescription)
                    }
                    // Update Table View
                    DispatchQueue.main.async {
                        self.data[1] = newEmail
                        self.profileTV.reloadData()
                        self.validationMessage.textColor = .green
                        self.validationMessage.text = "Email was successfully changed."
                    }
                }
            }
        }
    }
    
    private func validatedUserName(_ newUsername: String) {
        // Update Auth user
        let changeRequest = authUser.createProfileChangeRequest()
        changeRequest.displayName = newUsername
        changeRequest.commitChanges { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            } else {
                // Update Firestore user
                self.userDocRef.updateData(["displayName": newUsername]) { error in
                    if let error = error {
                        self.validationMessage.textColor = .red
                        self.validationMessage.text = error.localizedDescription
                        debugPrint(error.localizedDescription)
                    }
                    // Update Table View
                    DispatchQueue.main.async {
                        self.data[0] = newUsername
                        self.profileTV.reloadData()
                        self.validationMessage.textColor = .green
                        self.validationMessage.text = "Username was successfully changed."
                    }
                }
            }
        }
    }
    
    private func validateUserPassword(_ newPassword: String, _ reEnteredNP: String) {
        guard newPassword == reEnteredNP else {
            self.validationMessage.textColor = .red
            validationMessage.text = "Passwords does not match, please enter valid new password."
            return
        }
        // Update Auth user
        authUser.updatePassword(to: newPassword) { (error) in
            if let error = error {
                self.validationMessage.textColor = .red
                self.validationMessage.text = error.localizedDescription
                debugPrint(error.localizedDescription)
            } else {
                self.validationMessage.textColor = .green
                self.validationMessage.text = "Password was successfully changed."
            }
        }
    }
    
    private func openPremiumProfileVC() {
        let premiumProfileVC = PremiumProfileViewController()
        premiumProfileVC.user = user
        premiumProfileVC.delegate = self
        present(premiumProfileVC, animated: true, completion: nil)
    }
    
    // MARK:- Layout functions
    
    private func setupNavigation() {
        navigationItem.title = "Settings"
        navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Optima Regular", size: 30)!]
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    private func setupImagePicker() {
        let tappedImage = UITapGestureRecognizer(target: self, action: #selector(openImagePicker(_:)))
        userImage.isUserInteractionEnabled = true
        userImage.addGestureRecognizer(tappedImage)
        editImageBtn.addTarget(self, action: #selector(openImagePicker(_:)), for: .touchUpInside)
        imagePicker.delegate = self
    }
    
    private func setupView() {
        let vStack1 = VerticalStackView(
            arrangedSubviews: [userImage, editImageBtn, validationMessage],
            spacing: 5,
            alignment: .center)
        
        view.addSubview(profileTV)
        view.addSubview(vStack1)
        
        NSLayoutConstraint.activate([
            vStack1.bottomAnchor.constraint(equalTo: profileTV.topAnchor, constant: -40),
            vStack1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            validationMessage.widthAnchor.constraint(equalToConstant: width * 0.9),
            userImage.widthAnchor.constraint(equalToConstant: width * 0.55),
            userImage.heightAnchor.constraint(equalToConstant: width * 0.55),
            profileTV.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileTV.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            profileTV.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32)
        ])
        
    }
}

// MARK:- ProfileSettingsViewController extentions

extension ProfileSettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.userImage.image = pickedImage
            RepositoryFactory.createUserRepository().uploadImage(image: pickedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ProfileSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! yTableViewCell
        cell.title.text = data[indexPath.row]
        if indexPath.row == 3 {
            cell.title.font = UIFont(name: "Optima Bold", size: 20)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
            case 0:
                tapCell(withText: "Username")
            case 1:
                tapCell(withText: "Email")
            case 2:
                tapCell(withText: "Password")
            case 3:
                openPremiumProfileVC()
            default:
                return
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont(name: "Optima Regular", size: 20)
        header.textLabel?.textColor = .black
        header.textLabel?.frame = header.frame
        
        header.contentView.backgroundColor = UIColor(red: 15/255, green: 143/255, blue: 212/255, alpha: 0.5)
        header.textLabel?.textAlignment = .center
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:
                return "ACCOUNT SETTINGS"
            default:
                return "ADVANCED SETTINGS"
        }
    }
}

extension ProfileSettingsViewController: ChangePremium {
    func changePremium(toActive: Bool) {
        self.data[3] = toActive ? "Your profile is Premium" : "Your profile is not Premium"
        self.profileTV.reloadData()
    }
}
