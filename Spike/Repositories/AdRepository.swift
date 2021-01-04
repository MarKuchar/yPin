//
//  AdRepository.swift
//  Spike
//
//  Created by Cornerstone on 2020-10-17.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import Geofirestore


protocol AdRepository {
    
    func insert(newAd ad: Ad, withContent content: yAdContent, completion: ((_ ad: Ad) -> Void)?) -> Void
    
    func get(withId docId: String, completion: @escaping (_ ads: Ad) -> Void) -> Void
    
    func getAll(completion: @escaping (_ ads: [Ad]) -> Void) -> Void
    
    func fetchTop(from geoLocation: GeoLocation, completion: @escaping (_ ads:[Ad]) -> Void) -> Void
    
}

public class AdRepositoryImpl: AdRepository {
    
    fileprivate let collectionNameAds = "ads"
    fileprivate let collectionNameAdContents = "adContents"
    fileprivate let collectionNameGeoLocation = "geoLocation"
    
//    // local emulator
//    fileprivate var settings : FirestoreSettings = {
//        let settings = Firestore.firestore().settings
//        settings.host = "localhost:8080"
//        settings.isPersistenceEnabled = false
//        settings.isSSLEnabled = false
//        return settings
//    } ()
    
    fileprivate lazy var db = Firestore.firestore()
    fileprivate lazy var refColAds = db.collection(collectionNameAds)
    fileprivate lazy var refColAdContents = db.collection(collectionNameAdContents)
    fileprivate lazy var refColAdsGeoLocation = GeoFirestore.init(collectionRef: refColAds)
    
    
    fileprivate lazy var functions = Functions.functions()
    
//    init() {
//        let settings = Firestore.firestore().settings
//        settings.host = "localhost:8080"
//        settings.isPersistenceEnabled = false
//        settings.isSSLEnabled = false
//        Firestore.firestore().settings = settings
//    }
    
    func get(withId docId: String, completion: @escaping (Ad) -> Void) {
        self.refColAds.document(docId).getDocument { (snap, error) in
            guard let snap = snap, snap.exists else { return }
            
            if let ad = try? snap.data(as: Ad.self) {
                completion(ad)
            }
        }
    }
    
    func getAll(completion: @escaping (_ ads: [Ad]) -> Void) -> Void {
        self.refColAds.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            }
            
            guard let snapshot = querySnapshot else { return }
            let result: [Ad] = snapshot.documents.compactMap() { document in
                do {
                    var ad = try document.data(as: Ad.self)
                    ad?.uid = document.documentID
                    return ad
                } catch let e {
                    print("Error getting documents: \(e)")
                }
                return nil
            }
            completion(result)
        }
    }
    
    func insertAdContent(newContent content: yAdContent, completion: ((String) -> Void)?) {
//        do {
//            let refcontent = self.refColAdContents.document()
//            try refcontent.setData(from: content)
//            guard let completiionAux = completion else { return }
//            completiionAux(refcontent.documentID)
//        } catch {
//            print("Error")
//        }
    }
    
    func insert(newAd ad: Ad, withContent content: yAdContent, completion: ((_ ad: Ad) -> Void)? = nil) {
        do {
            var ad = ad
            let refAd = self.refColAds.document()
            let refAdContent = self.refColAdContents.document()
            
            try refAdContent.setData(from: content) // persist ad's content
            
            ad.uid = refAd.documentID
            switch ad.contentType {
            case .template:
                guard let templateContent = content as? yTemplateContent,
                      let templateName = templateContent.templateName
                else {
                    refAdContent.delete()
                    return
                }
                ad.content = "\(templateName)|\(refAdContent.documentID)"
            default:
                ad.content = refAdContent.documentID
            }
            
            let geoLocation = ad.geoLocation
            ad.geoLocation = nil
            try refAd.setData(from: ad) // persist ad
            guard let location = geoLocation else {
//                refAd.delete()
//                refAdContent.delete()
                return
            }
            // persist ad's location
            refColAdsGeoLocation.setLocation(geopoint: location.toGeoPoint(), forDocumentWithID: refAd.documentID) { _ in
                ad.geoLocation = geoLocation
                guard let completionAux = completion else { return }
                completionAux(ad)
            }
        } catch {
            print("Error")
        }
    }
    
    func fetchTop(from geoLocation: GeoLocation, completion: @escaping ([Ad]) -> Void) {
//        self.fetchTopCloudFunction(from: geoLocation, completion: completion)
        self.fetchTopIOsGeoFirestore(from: geoLocation, completion: completion)
    }
    
    func fetchTopIOsGeoFirestore(from geoLocation: GeoLocation, completion: @escaping ([Ad]) -> Void) {
        var dic = [String : GeoLocation]()
        let distante = 5.6
        let limit = 8
        let geoQuery  = self.refColAdsGeoLocation.query(withCenter: geoLocation.toGeoPoint(), radius: distante)
        geoQuery.searchLimit = limit
        let _ = geoQuery.observe(.documentEntered) { (docKey, location) in
            if let key = docKey,
               let latitude = location?.coordinate.latitude,
               let longitude = location?.coordinate.longitude {
                dic[key] = GeoLocation.init(latitude: latitude, longitude: longitude)
            }
        }
        
        let _ = geoQuery.observeReady {
            let overItens = dic.count > limit ? dic.count - limit : 0;
            
            self.refColAds.whereField("uid", in: dic.dropLast(overItens).map { (key, value) in key }).getDocuments { (snap, err) in
                guard err == nil else {
                    debugPrint(err!)
                    return
                }
                guard let snap = snap else {
                    print("No Data")
                    return
                }

                let ads = snap.documents.compactMap { (docSnap) -> Ad? in
                    if var ad = try? docSnap.data(as: Ad.self), self.validateAd(ad) {
                        ad.geoLocation = dic[docSnap.documentID]
                        return ad
                    }
                    return nil
                }
                completion(ads)
            }
            geoQuery.removeAllObservers()
        }
    }
    
    func validateAd(_ ad: Ad) -> Bool {
        let date = Date()
        guard let startDate = ad.startDate, let endDate = ad.endDate else {
            return false
        }
        guard startDate < date else {
            return false
        }
        guard endDate > date else {
            refColAds.document(ad.uid!).updateData(["active": false])
            refColAds.document(ad.uid!).updateData(["active": false])
            return false
        }
        if !ad.active {
            refColAds.document(ad.uid!).updateData(["active": true])
        }
        return true
    }

    func fetchTopCloudFunction(from geoLocation: GeoLocation, completion: @escaping ([Ad]) -> Void) {
//        self.functions.useFunctionsEmulator(origin: "http://localhost:5001")
        self.functions.httpsCallable("fetchTop").call(["latitude": geoLocation.latitude, "longitude": geoLocation.longitude]) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                      let code = FunctionsErrorCode(rawValue: error.code)
                      let message = error.localizedDescription
                        print(code, message)
                    }
            }
            
            if let data = result?.data as? NSArray  {
                
                let decoder = JSONDecoder()
                
                let ads : [Ad] = data.compactMap() { element in
//                    if let dic = element as? NSDictionary {
//                        return Ad.init(fromDic: dic)
//                    }
//                    return nil
                    do {
                        return try decoder.decode(Ad.self, from: JSONSerialization.data(withJSONObject: element as! NSDictionary))
                    } catch {
                        print(error)
                        return nil
                    }
                }
                completion(ads)
            }
        }
    }
    
}

extension GeoLocation {
    func toGeoPoint() -> GeoPoint {
        return GeoPoint.init(latitude: self.latitude, longitude: self.longitude)
    }
}


