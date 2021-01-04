//
//  ARViewController.swift
//  Spike
//
//  Created by Cornerstone on 2020-10-16.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth
import CoreLocation
import ARKit

class yARViewController: UIViewController {
    
    private lazy var authUser = Auth.auth().currentUser!
    private lazy var docRef = Firestore.firestore().collection("users").document(authUser.uid)
    private let furthestVisiblePin: Float = 50
    private var startedLoadingPOIs = false
    private var originalTransform: SCNMatrix4!
    private var ads: [Ad] = []
    
    lazy var arView: ARSCNView = {
        let arView = ARSCNView()
        arView.showsStatistics = true
        return arView
    }()
    
    fileprivate let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }()
    
    lazy var profileBtn = yARButton(title: "UserIcon.png")
    
    lazy var addAdBtn = yARButton(title: "Add.png")
    
    lazy var savedAdsBtn = yARButton(title: "Saved.png")
    
    lazy var adInfo = yUnavailableAdLabel()

    fileprivate var currentLocation: GeoLocation {
        return GeoLocation.init(latitude: 49.280476, longitude: -123.130875)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        ARConfiguration()
        determineCurrentLocation()
        
        docRef.getDocument { (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            if let snap = snap {
                if let data = try? snap.data(as: User.self) {
                    self.addAdBtn.isHidden = !data.premium
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        fetchTop()
        
        profileBtn.addTarget(self, action: #selector(navigateToProfileView(_ :)), for: .touchUpInside)
        addAdBtn.addTarget(self, action: #selector(navigateToAddAdvertisementView(_ :)), for: .touchUpInside)
        savedAdsBtn.addTarget(self, action: #selector(navigateToSavedAdsView(_ :)), for: .touchUpInside)
        setupGestureRecognizer()
        
        setupNVC()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        arView.session.pause()
    }
    
    private func ARConfiguration() {
        // Class that track device's movement with six degrees of freedom (6DOF).
        // Virtual object appears to stay in the sme place relative to the real world
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        configuration.planeDetection = .horizontal
//        self.arView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        self.arView.delegate = self
        self.arView.session.run(configuration)
    }
    
    private func fetchTop() {
        let currentLocation = GeoLocation(latitude: 49.282295, longitude: -123.125953)
        RepositoryFactory.createAdRepository().fetchTop(from: currentLocation, completion: { topAds in
            if topAds.count > 0 {
                self.ads = topAds.shuffled()
                print(self.ads.count)
            } else {
                self.adInfo.text = "There're not any cupons around you now"
                self.adInfo.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.3)
            }
            let _ = self.ads.map { ad in
                // Should be setting for notification in the Main thread?
                let center = CLLocationCoordinate2D(latitude: ad.geoLocation!.latitude, longitude: ad.geoLocation!.longitude)
                let region = CLCircularRegion(center: center, radius: 1.0, identifier: "AdArea")
                region.notifyOnEntry = true
                region.notifyOnExit = false
                let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
                self.notificationRequest(trigger: trigger)
            }
        })
    }
    
    private func setupGestureRecognizer() {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(openAd(_:)))
        arView.addGestureRecognizer(tapGR)
    }
    
    private func setupView() {
        view.addSubview(arView)
        arView.matchParent()
        view.addSubview(profileBtn)
        view.addSubview(addAdBtn)
        view.addSubview(savedAdsBtn)
        view.addSubview(adInfo)
        view.bringSubviewToFront(adInfo)
        adInfo.centerXYin(view)
        NSLayoutConstraint.activate([
            adInfo.widthAnchor.constraint(equalToConstant: view.frame.width * 0.9),
            profileBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            profileBtn.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            addAdBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addAdBtn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            savedAdsBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            savedAdsBtn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    // Will setup the NVC for controllers that will be pushed on the current one
    private func setupNVC() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor = .black
    }
    
    @objc func openAd(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(in: arView)
        let hitTest = arView.hitTest(touchLocation, options: nil)
        if !hitTest.isEmpty {
            let result = hitTest.first!.node
            if let adId = result.name {
                print("The tapped node with id: \(adId)")
                self.openAd(withId: adId)
            }
        }
    }
    
    @objc func navigateToProfileView(_ btn: UIButton) {
        let profileView = ProfileViewController()
        navigationController?.pushViewController(profileView, animated: true)
    }
    
    @objc func navigateToAddAdvertisementView(_ btn: UIButton) {
        let vc = UINavigationController(rootViewController: yAddAdViewController())
        present(vc.translucentNavController(), animated: true, completion: nil)
    }
    
    @objc func navigateToSavedAdsView(_ btn: UIButton) {
        let vc = UINavigationController(rootViewController: ySavedAdsViewController())
        present(vc.translucentNavController(), animated: true, completion: nil)
    }
    
    private func randomNumber(from first: CGFloat, to second: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(first - second) + min(first, second)
    }
    
    // MARK:- Augmented reality methods
    
    func createPin(withId adId: String, icon iconName: String, node: SCNNode, anchor: ARPlaneAnchor) -> SCNNode {
        // We found an anchor plane for the scene and now we place a node randomly on in
        // Get the scene from art.scnassets
        let scene = SCNScene(named: iconName)!
        let pin = scene.rootNode.clone()
        pin.name = adId
        pin.enumerateChildNodes { (node, _) in
            node.name = adId
        }
        pin.position = SCNVector3(anchor.center.x, -0.5, anchor.center.z)
        return pin
    }
    
    func createPlane(with anchor: ARPlaneAnchor) -> SCNNode {
        // Extent property gives estimated size of the detected plane
        let planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        let node = SCNNode(geometry: planeGeometry)
        node.eulerAngles.x = -Float.pi / 2
        node.opacity = 0
        return node
    }
    
    func removeNode(named: String) {
        arView.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == named {
                node.removeFromParentNode()
            }
        }
    }
    
    private func isValidDistanceBetween(_ nodeA: SCNNode, _ nodeB: SCNNode) -> Bool {
        // SceneKit coordinates are in meters: 1 -> 1 meter.
        // Let's suggest that the distance between two nodes will be more than 2m.
        let distX = abs(nodeA.position.x - nodeB.position.x)
        let distZ = abs(nodeA.position.z - nodeB.position.z)
        let distance = sqrt(pow(distX, 2) + pow(distZ, 2))
//        print("Distance between new node and \(nodeB.name!) is: \(distance)")
        return distance > 2
    }
    
    func isValidatedPositionOf(_ nodeA: SCNNode, in parentNode: SCNNode) -> Bool {
        var isValid = true
        parentNode.enumerateChildNodes { (nodeB, _) in
            if let name = nodeB.name, name.count == 20, !isValidDistanceBetween(nodeA, nodeB) {
                isValid = false
                return
            }
        }
        return isValid
    }
    
    // MARK:- Static methods (yNode, yMatrix) that we will be possibly using to place an object at the correct location facing to us
    
    // An ARAnchor gives you the ability to track positions and orientations of models relative to the camera.
    // In our case maybe we don't need to set an anchor.
    // Translate and position the node
    func positionModel(pin: SCNNode, atLocation location: CLLocation) {
        // It's like creating anchor to the specific location 'position the model to the correct location'
        let coordinate = CLLocationCoordinate2D(latitude: 49.24297, longitude: -123.118729)
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        arView.session.add(anchor: yNode.translateNode(location: location, userLocation: locationManager.location!))
        // Or seting the position of the pin
        // pin.position = translateNode(location)
    }
    
    
    // MARK:- Location manager methods
    
    private func determineCurrentLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    // MARK:- Notification manager methods
    
    private func notificationRequest(trigger: UNLocationNotificationTrigger) {
        let notification = UNMutableNotificationContent()
        notification.title = "You've entered the area with the Pin"
        notification.sound = .default
        
        let request = UNNotificationRequest(identifier: "destAlarm", content: notification, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if error == nil {
                //                print("Successful notification")
            } else {
                print(error ?? "Error")
            }
        })
    }
    
    // MARK:- Seugue methods
    
    fileprivate func openAd(withId adId: String) {
        let adRepository = RepositoryFactory.createAdRepository()
        adRepository.get(withId: adId) { (ad) in
            guard let contentType = ad.contentType,
                  let content = ad.content,
                  contentType == .template else { return self.showCanNotOpenAd()}

            let arr = content.split(separator: "|")
            if let subS1 = arr.first,
               let subS2 = arr.last {
                
                let templateName = String.init(subS1)
                let contentId = String.init(subS2)
                
                if let vc = yTemplateViewControllerFactory.creatTemplateViewController(
                    withName: templateName, andState: .onlyRead) {
                    
                    let contentRepository = RepositoryFactory.createTemplateRepository()
                    contentRepository.getContent(withId: contentId) { (templateData) in
                        DispatchQueue.main.async {
                            vc.loadData(from: templateData, withAd: adId)
                            self.navigationController?.present(vc, animated: true)
                        }
                    }
                }
            } else {
                self.showCanNotOpenAd()
            }
        }
    }
    
    func showCanNotOpenAd() {
        self.showAlertConfirmation(withTitle: "Attention", andMessage: "Unfortunately this Ad can't be opened.")
    }
}

// MARK:- Extentions

extension yARViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Place node to render the objects base of the current location
        
        if !startedLoadingPOIs {
            startedLoadingPOIs = true
            /// Here we can fetch while the user will be moving 
//            fetchTop()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error requesting location: \(error.localizedDescription)")
    }
}

extension yARViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // This method is called when ARkit reports finding a new anchor. An anchor
        // is both a position and an orientation for placing objects in an AR scene.
        guard let newPlaneAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        DispatchQueue.main.async {
            node.addChildNode(self.createPlane(with: newPlaneAnchor))
            if !self.ads.isEmpty {
                let ad = self.ads.removeFirst()
                let icon = ad.adType?.getFilePath() ?? yAdType.pin.getFilePath()
                let pin = self.createPin(withId: ad.uid!, icon: icon, node: node, anchor: newPlaneAnchor)
                node.addChildNode(pin)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // After detecting that the plane is bigger than the initial one, we resize the plane
        guard let planeAnchor = anchor as? ARPlaneAnchor,
              let planeNode = node.childNodes.first,
              let plane = planeNode.geometry as? SCNPlane else {
            return
        }
        DispatchQueue.main.async {
            guard !self.ads.isEmpty else {
                return
            }
            // Adjust the recalculated plane
            planeNode.position = SCNVector3(planeAnchor.center.x, 0,
                                            planeAnchor.center.z)
            plane.width = CGFloat(planeAnchor.extent.x)
            plane.height = CGFloat(planeAnchor.extent.z)
            
            // Create a dummy pin in the center of the expanded plane, if the distance bettween the child nodes
            // and the center is greater than 2m, than place a new pin in the center!
            let dummyPin = SCNNode()
            dummyPin.position =  SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
            if self.isValidatedPositionOf(dummyPin, in: node) {
                let ad = self.ads.removeFirst()
                let icon = ad.adType?.getFilePath() ?? yAdType.pin.getFilePath()
                let pin = self.createPin(withId: ad.uid!, icon: icon, node: node, anchor: planeAnchor)
                node.addChildNode(pin)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        // Plane anchor was removed
    }
}

