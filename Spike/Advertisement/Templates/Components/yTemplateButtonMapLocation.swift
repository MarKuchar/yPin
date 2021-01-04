//
//  yTemplateButtonMapLocation.swift
//  Spike
//
//  Created by Cayo on 2020-12-23.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit
import CoreLocation

@IBDesignable
class yTemplateButtonMapLocation: UIButton {

    weak var templateVC: yTemplateViewController?
    weak var delegate: yTemplateButtonMapLocationDelegate?
    
    var editable: Bool = false {
        didSet {
            updateComponent()
        }
    }
    
    var location: CLLocationCoordinate2D?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    let openMapInput = UIAction.init(title: "popupInput") { action in
        guard let btn = action.sender as? yTemplateButtonMapLocation else { return }
        let vc = yMapSetLocationViewController.init()
        vc.delegate = btn
        btn.templateVC?.navigationController?.pushViewController(vc, animated: true)
    }
    
    let openMap = UIAction.init(title: "openMap") { action in
        guard let btn = action.sender as? yTemplateButtonMapLocation, let location = btn.location else { return }
        btn.delegate?.openMap(onLocation: location)
    }
    
    func updateComponent() {
        if self.editable {
            self.removeAction(self.openMap, for: .touchUpInside)
            self.addAction(self.openMapInput, for: .touchUpInside)
        } else {
            self.removeAction(self.openMapInput, for: .touchUpInside)
            self.addAction(self.openMap, for: .touchUpInside)
        }
    }
    
    func setup( withTemplateVC vc: yTemplateViewController, andDelegate delegate: yTemplateButtonMapLocationDelegate, editable: Bool, andInitialValue initialValue: CLLocationCoordinate2D? = nil) {
        self.templateVC = vc
        self.delegate = delegate
        self.location = initialValue
        self.editable = editable
    }
    
}

protocol yTemplateButtonMapLocationDelegate: yMapSetLocationViewControllerDelegate {
    
    func openMap(onLocation location: CLLocationCoordinate2D)
    
}

extension yTemplateButtonMapLocation: yMapSetLocationViewControllerDelegate {
   
    func locationSelected(_ location: CLLocationCoordinate2D) {
        self.location = location
        self.delegate?.locationSelected(location)
    }
    
}
