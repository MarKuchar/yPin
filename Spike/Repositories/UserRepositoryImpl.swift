//
//  UserRepository.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-11-02.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import Foundation
import Firebase

protocol UserRepository {
    func createUser(with profileName: String,
                    email: String,
                    password: String,
                    image: UIImage?,
                    completion: @escaping (_ success: Bool, _ error: Error?) -> Void)
    
    func downloadImage(from url: URL, completion: @escaping (_ image: UIImage?) -> Void)
    
    func uploadImage(image: UIImage?)
    
    func fetchSavedAds(userID: String, completion: @escaping (_ ads: [ySavedAd]) -> Void)
    
    func saveNewAd(userID: String, adId: String, urlImage: UIImage, completion: @escaping (_ success: Bool, _ error: AdError?) -> Void)
    
    func discardSavedAd(userID: String, adId: String, completion: @escaping (_ success: Bool) -> Void)
}

class UserRepositoryImpl: UserRepository {
    
    fileprivate static var db = Firestore.firestore()
    fileprivate static var refColUsers = db.collection("users")
    static let shared = UserRepositoryImpl()
    
    func createUser(with profileName: String,
                    email: String,
                    password: String,
                    image: UIImage?,
                    completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        // Create user in auth table
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let err = error {
                // User wasn't created check error, show message
                print(err.localizedDescription)
                completion(false, err)
                return
            }
            if user != nil {
                // 1. Upload user to Firebase storage
                self.saveProfile(with: profileName, email: email, and: nil) { success in
                    if let image = image {
                        // 2. Save profile data to firebase database with the image!
                        self.uploadImage(image: image)
                    }
                    completion(success, nil)
                }
            } else {
                print("User wasn't created")
            }
        }
    }
    
    func uploadImage(image: UIImage?) {
        guard let image = image else {
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid  else { return }
        let storageRef = Storage.storage().reference().child("user/\(uid)")
        
        imageToUrl(image, storageRef: storageRef) { urlImage in
            guard let currentUser = Auth.auth().currentUser else { return }
            guard let url = urlImage else { return }
            
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = currentUser.displayName
            changeRequest?.photoURL = urlImage
            
            changeRequest?.commitChanges(completion: { error in
                guard error == nil else {
                    print("Error: \(error!.localizedDescription)")
                    return
                }
            })
            
            let imageField: [String: Any] = ["photoURL": url.absoluteString]
            Firestore.firestore().collection("users/").document(currentUser.uid).setData(imageField, merge: true)
        }
    }
    
    func downloadImage(from url: URL, completion: @escaping (_ image: UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler:  { (data, response, error) in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            completion(UIImage(data: data))
        }).resume()
    }
    
    func fetchSavedAds(userID: String, completion: @escaping (_ ads: [ySavedAd]) -> Void) {
        Firestore.firestore().collection("users").document(userID).collection("savedAds").getDocuments { (snapData, error) in
            if let error = error {
                debugPrint(error)
                return
            }
            if let snap = snapData {
                var savedAdsId: [ySavedAd]
                savedAdsId = snap.documents.compactMap { (docSnap) -> ySavedAd? in
                    return try! docSnap.data(as: ySavedAd.self)
                }
                completion(savedAdsId)
            } else {
                completion([])
            }
        }
    }
    
    func saveNewAd(
        userID: String,
        adId: String,
        urlImage: UIImage,
        completion: @escaping (_ success: Bool, _ error: AdError?) -> Void) {
        let storageRef = Storage.storage().reference().child("savedAds/\(userID)/\(adId)")
        
        imageToUrl(urlImage ,storageRef: storageRef) { urlImage in
            let savedAdObject = [
                "docId": adId,
                "docPictureUrl": urlImage?.absoluteString ?? ""
            ]
            
            let colRef = Firestore.firestore().collection("users").document(userID).collection("savedAds")
            let ref = Firestore.firestore().collection("users").document(userID).collection("savedAds").document(adId)
            
            colRef.getDocuments { (colSnap, error) in
                guard let colSnap = colSnap, error == nil else {
                    return
                }
                if colSnap.count > 5 {
                    completion(false, AdError.CapacityError)
                } else {
                    ref.getDocument { (docSnap, error) in
                        guard let docSnap = docSnap, error == nil else {
                            completion(false, AdError.DuplicateError)
                            return
                        }
                        if !docSnap.exists {
                            ref.setData(savedAdObject)
                            completion(true, nil)
                        }
                    }
                }
            }
        }
    }
    
    func discardSavedAd(userID: String, adId: String, completion: @escaping (_ success: Bool) -> Void) {
        let ref = Firestore.firestore().collection("users").document(userID).collection("savedAds").document(adId)
        ref.delete() { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    private func saveProfile(with displayName: String,
                             email: String,
                             and urlImage: URL?,
                             comletion: @escaping (_ success: Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userObject = [
            "displayName": displayName,
            "email": email,
            "photoURL": urlImage?.absoluteString ?? "",
            "premium": true
        ] as [String: Any]
        Firestore.firestore().collection("users/").document(uid).setData(userObject) { error in
            if error == nil {
                let changeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges { (error) in
                    if let error = error {
                        debugPrint(error.localizedDescription)
                    }
                }
                comletion(true)
            }
        }
    }
    
    private func imageToUrl(_ image: UIImage, storageRef: StorageReference, completion: @escaping (_ url: URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.70) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        storageRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil && metaData != nil {
                storageRef.downloadURL(completion: { url, error in
                    guard error == nil else { return }
                    if let url = url {
                        completion(url)
                    }
                })
            } else {
                completion(nil)
            }
        }
    }
}

enum AdError: Error {
    case CapacityError
    case DuplicateError
    
    var description: String {
        switch self {
            case .CapacityError:
                return "You already have 6 ads, please delete before saving a new one."
            case .DuplicateError:
                return "You already have this adverisment."
        }
    }
}
