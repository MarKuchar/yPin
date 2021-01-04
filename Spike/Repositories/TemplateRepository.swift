//
//  TemplateRepository.swift
//  Spike
//
//  Created by Cornerstone on 2020-11-16.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

protocol TemplateRepository {
    func getContent(withId: String, completion: @escaping (_: yTemplateContent) -> Void ) -> Void
    
    func fetchTemplates(completion: @escaping (_: [yTemplate]) -> Void) -> Void
    
    func fetchTemplateImageRef(withDocId docId: String, completion: @escaping (_: StorageReference) -> Void) -> Void
    
    func upload(image: UIImage, completion: @escaping (_ url:URL) -> Void) -> Void
    
    func downloadImage(from url: URL, completion: @escaping (_ image: UIImage?) -> Void)
    
}

class TemplateRepositoryImpl: TemplateRepository {
    
    fileprivate let collectionNameAdContents = "adContents"
    fileprivate let collectionNameTemplatePictures = "templates"
    fileprivate let storagePathTemplateImage = "templatePictures/"
    
    
    fileprivate lazy var db = Firestore.firestore()
    fileprivate lazy var storage = Storage.storage()
    fileprivate lazy var refColAdContents = db.collection(collectionNameAdContents)
    fileprivate lazy var refColTemplatePictures = db.collection(collectionNameTemplatePictures)
    
    func getContent(withId docId: String, completion: @escaping(yTemplateContent) -> Void) {
        refColAdContents.document(docId).getDocument { (snap, error) in
            if let error = error {
                // TODO
                print(error)
                return
            }
            if let snap = snap,
               let templateData = try? snap.data(as: yTemplateContent.self){
                completion(templateData)
            }
        }
    }
    
    func fetchTemplates(completion: @escaping ([yTemplate]) -> Void) {
        refColTemplatePictures.getDocuments { (querySnapshot, error) in
            if let error = error {
                // TODO
                print(error)
                return
            }
            guard let snapshot = querySnapshot else { return }
            let result: [yTemplate] = snapshot.documents.compactMap() { document in
                if let template = try? document.data(as: yTemplate.self) {
                    var template = template
                    template.name = document.documentID
                    return template
                }
                return nil
            }
            completion(result)
        }
    }
    
    func fetchTemplateImageRef(withDocId docId: String, completion: @escaping (StorageReference) -> Void) {
        let path = "\(self.storagePathTemplateImage)/\(docId)"
        let imageRef = self.storage.reference(withPath: path)
        completion(imageRef)
    }
    
    func downloadImage(from url: URL, completion: @escaping (_ image: UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler:  { (data, response, error) in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            completion(UIImage(data: data))
        }).resume()
    }
    
    func upload(image: UIImage, completion: @escaping (URL) -> Void) {
        
        let uuid = UUID.init().uuidString
        let imageRef = self.storage.reference().child("templateImages/\(uuid)")
        
        guard let imageData = image.pngData() else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        imageRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil && metaData != nil {
                imageRef.downloadURL(completion: { url, error in
                    guard error == nil else { return }
                    if let url = url {
                        completion(url)
                    }
                })
            }
        }
    }
    
}
