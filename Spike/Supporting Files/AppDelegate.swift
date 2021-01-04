//
//  AppDelegate.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-10-08.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GoogleSignIn
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    fileprivate var authListener: AuthStateDidChangeListenerHandle?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        DispatchQueue.main.async {
            self.authListener = Auth.auth().addStateDidChangeListener { auth, user in
                var vc : UIViewController
                if let user = user {
                    let userDocumentRef = Firestore.firestore().collection("users")
                    userDocumentRef.document(user.uid).getDocument { (snap, error) in
                        if let error = error {
                            debugPrint(error.localizedDescription)
                        }
                        if !snap!.exists {
                            let userObject = [
                                "displayName": user.displayName ?? "",
                                "email": user.email ?? "",
                                "photoURL": user.photoURL?.absoluteString ?? "",
                                "premium": false
                                ] as [String: Any]
                            Firestore.firestore().collection("users/").document(user.uid).setData(userObject) { error in
                                if error == nil {
                                }
                            }
                        }
                    }
//                    vc = MapViewController()
                    vc = yARViewController()
                } else {
                    vc = SignInViewController()
                }
                let window = UIApplication.shared.windows[0] as UIWindow;
                let navVC = UINavigationController(rootViewController: vc)
                window.rootViewController = navVC.translucentNavController()
                window.makeKeyAndVisible()
                UIView.transition(with: window,
                                  duration: 0.5,
                                  options: .transitionCrossDissolve,
                                  animations: nil,
                                  completion: nil)
            }
        }
        return true
    }
    
    // MARK:- UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running,
        // this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
        -> Bool {
            ApplicationDelegate.shared.application(
                application,
                open: url,
                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplication.OpenURLOptionsKey.annotation]
            )
            
            return GIDSignIn.sharedInstance().handle(url)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    // MARK:- Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Spike")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

// MARK: - Confirm to GIDSignInDelegate

//
//extension AppDelegate: GIDSignInDelegate {
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
//        // handle sign-in errors
//        // user.authentication.refreshToken
//        if let error = error {
//            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
//                print("The user has not signed in before or they have since signed out.")
//            } else {
//                print("error signing into Google \(error.localizedDescription)")
//            }
//            return
//        }
//
//        // Get credential object using Google ID token and Google access token
//        guard let authentication = user.authentication else { return }
//
//        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
//                                                       accessToken: authentication.accessToken)
//
//        // Authenticate with Firebase using the credential object
//        Auth.auth().signIn(with: credential) { (authResult, error) in
//            //handle sign-in errors
//            if let error = error {
//                if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
//                    print("The user has not signed in before or they have since signed out.")
//                } else {
//                    print("error signing into Google \(error.localizedDescription)")
//                }
//                return
//            }
//
//            // Get credential object using Google ID token and Google access token
//            guard let authentication = user.authentication else { return }
//
//            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
//                                                           accessToken: authentication.accessToken)
//
//            // Authenticate with Firebase using the credential object
//            Auth.auth().signIn(with: credential) { (authResult, error) in
//                if let error = error {
//                    print("authentication error \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//}
