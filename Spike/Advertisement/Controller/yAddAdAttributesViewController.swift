//
//  AddAdAttributesViewController.swift
//  Spike
//
//  Created by Cornerstone on 2020-11-11.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit
import PickerButton
import CoreLocation
import Firebase
import FirebaseFirestore

class yAddAdAttributesViewController: UIFormViewController {
    
    fileprivate var user = Auth.auth().currentUser!
    var contentData: yTemplateContent!

    lazy var locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        lm.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        lm.requestWhenInUseAuthorization()
        lm.delegate = self
        return lm
    }()
    
    fileprivate var currentGeoLocation: GeoLocation {
        let (latitude, longitude) = (locationManager.location!.coordinate.latitude, locationManager.location!.coordinate.longitude)
        return GeoLocation.init(latitude: latitude, longitude: longitude)
    }

    let adTypeDelegate = DataAdType()
    
    lazy var adTypePickerButton: PickerButton = {
        let pb = PickerButton()
        pb.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        pb.delegate = adTypeDelegate
        pb.titleLabel?.font = UIFont(name: "Optima Regular", size: 20)
        pb.titleLabel?.textColor = .systemRed
        return pb
    }()
    
    lazy var adTypeSession: UIView = {
        let label = UILabel()
        label.text = "Ad Type"
        label.textColor = .black
        label.font = UIFont(name: "Optima Regular", size: 20)
        let v = UIStackView.init(arrangedSubviews: [label, self.adTypePickerButton])
        v.axis = .horizontal
        v.distribution = .fill
        return v
    }()

    let extraTimeDelegate = DataExtraTime()
    
    lazy var extraTimePickerButton: PickerButton = {
        let pb = PickerButton()
        pb.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        pb.delegate = extraTimeDelegate
        pb.titleLabel?.font = UIFont(name: "Optima Regular", size: 20)
        pb.titleLabel?.textColor = .systemRed
        return pb
    }()
    
    lazy var extraTimeSession: UIView = {
        let label = UILabel()
        label.text = "Extra Time"
        label.textColor = .black
        label.font = UIFont(name: "Optima Regular", size: 20)
        let v = UIStackView.init(arrangedSubviews: [label, self.extraTimePickerButton])
        v.axis = .horizontal
        v.distribution = .fill
        return v
    }()
    
    lazy var prioritySwitch: UISwitch = {
        let s = UISwitch()
        s.onTintColor = .systemRed
        return s
    }()
    
    lazy var prioritySession: UIView = {
        let label = UILabel()
        label.text = "Priority"
        label.textColor = .black
        label.font = UIFont(name: "Optima Regular", size: 20)
        let sv = UIStackView.init(arrangedSubviews: [label, prioritySwitch])
        sv.axis = .horizontal
        sv.distribution = .fill
        return sv
    }()
    
    lazy var stack: UIStackView = {
        let sv = UIStackView.init(arrangedSubviews: [self.adTypeSession, self.extraTimeSession, self.prioritySession])
        sv.axis = .vertical
        sv.spacing = UIConstants.StackView.spacing
        return sv
    }()
    
    lazy var contentView: UIView = {
        let v = UIView()
        v.backgroundColor = .init(white: 1, alpha: 0.2)
        return v
    }()
    
    lazy var scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.applyBackground(withLayer: .backgroundGrid)
        
        self.setupLayout()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(createAd))
        self.navigationItem.rightBarButtonItem?.tintColor = .black
    }

    func setupLayout() {
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.contentView)
        self.contentView.addSubview(self.stack)
        
        self.scrollView.matchParent()
        self.contentView.matchParent()
        self.contentView.dimensions(widthAnchor: self.scrollView.widthAnchor)
        self.stack.matchParent(padding: .init(top: UIConstants.padding, left: UIConstants.padding, bottom: UIConstants.padding, right: UIConstants.padding))
    }
    
    @objc func createAd() {
        let geoLocation = self.currentGeoLocation
        let userUid = self.user.uid
        let adType = self.adTypeDelegate.values[self.adTypePickerButton.selectedRow(inComponent: 0)]
        let content = self.contentData!
        let priority = self.prioritySwitch.isOn
        let now = Date()
        let creationDate = now
        let startingDate = now
        let endDate = generateEndDate(from: startingDate)
        let newAd = Ad.init(ownerUid: userUid, contentType: .template, adType: adType, active: true, priority: priority, creationDate: creationDate, startDate: startingDate, endDate: endDate, geoLocation: geoLocation)
        
        let adRepository = RepositoryFactory.createAdRepository()
        adRepository.insert(newAd: newAd, withContent: content) { _ in
            DispatchQueue.main.async {
                self.showAlertConfirmation(withTitle: "Attention", andMessage: "Advertisment was created") {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func generateEndDate(from baseDate: Date) -> Date {
        var days = 7
        let pickerRow = self.extraTimePickerButton.selectedRow(inComponent: 0)
        if pickerRow > 0 {
            days += DataExtraTime.extraDays[pickerRow]
        }
        return Calendar.current.date(byAdding: .day, value: days, to: baseDate)!
    }

}

extension yAddAdAttributesViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .authorizedAlways:
                print("authorizedAlways")
            case .authorizedWhenInUse:
                print("authorizedWhenInUse")
            case .denied:
                print("denied")
            case .notDetermined:
                print("notDetermined")
            case .restricted:
                print("restricted")
            default:
                print("default case")
                return
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error requesting location: \(error.localizedDescription)")
    }
    
}

class DataExtraTime: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    fileprivate static let extraDays = [0, 3, 7, 15, 30]
    fileprivate var pickerValues = ["None", "3 days", "7 days", "15 days", "30 days"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerValues[row]
    }
    
}

class DataAdType: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var values = yAdType.allCases
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.values.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let type = self.values[row]
        return (type == .pin) ? "Default" : type.rawValue
    }
    
}

