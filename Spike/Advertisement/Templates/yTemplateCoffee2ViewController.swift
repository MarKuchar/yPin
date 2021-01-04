//
//  yTemplateCoffee2ViewController.swift
//  Spike
//
//  Created by Cayo on 2021-01-03.
//  Copyright © 2021 Martin Kuchar. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class yTemplateCoffee2ViewController: yTemplateViewController {

    @IBOutlet weak var titleLabel: yTemplateLabel!
    
    @IBOutlet weak var subtitleLabel: yTemplateLabel!
    
    @IBOutlet weak var logoImage: yTemplateImage!
    
    @IBOutlet weak var footerLabel: yTemplateLabel!
    
    @IBOutlet weak var locationButton: yTemplateButtonMapLocation!
    
    @IBOutlet weak var websiteButton: yTemplateButtonWebsite!
    
    var title1: String? = nil {
        didSet {
            titleLabel?.text = title1
            checkTemplateFilled()
        }
    }

    var title2: String? = nil {
        didSet {
            subtitleLabel?.text = title2
            checkTemplateFilled()
        }
    }
    
    var imageURL: URL? = nil {
        didSet {
            checkTemplateFilled()
        }
    }
    
    var footer: String? = nil {
        didSet {
            footerLabel?.text = footer
            checkTemplateFilled()
        }
    }
    
    var location: CLLocationCoordinate2D? = nil {
        didSet {
            checkTemplateFilled()
        }
    }
    
    var url: URL? = nil {
        didSet {
            checkTemplateFilled()
        }
    }
    

    func checkTemplateFilled() {
        templateFilled = self.title1 != nil && self.title2 != nil && self.footer != nil && self.imageURL != nil && self.location != nil && self.url != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.titleLabel.setup(
            withTemplateVC: self,
            andDelegate: self,
            editable: self.state! == .editable,
            initialValue: self.title1)

        self.subtitleLabel.setup(
            withTemplateVC: self,
            andDelegate: self,
            editable: self.state! == .editable,
            initialValue: self.title2)

        self.footerLabel.setup(
            withTemplateVC: self,
            andDelegate: self,
            editable: self.state! == .editable,
            initialValue: self.footer)

        self.logoImage.setup(
            withTemplateVC: self,
            andDelegate: self,
            editable: self.state! == .editable,
            initialValue: self.imageURL)
        
        self.locationButton.setup(withTemplateVC: self, andDelegate: self, editable: self.state! == .editable, andInitialValue: self.location)
        
        self.websiteButton.setup(withTemplateVC: self, andDelegate: self, editable: self.state! == .editable, andInitialValue: self.url)
    }

    override func generateData() -> yTemplateContent {
        let content = yTemplateContent.init()
        content.templateName = "yTemplateCoffee"
        content.text1 = self.title1
        content.text2 = self.title2
        content.text3 = self.footer
        content.url1 = self.imageURL
        content.url2 = self.url
        if let location = self.location {
            content.latitude = location.latitude
            content.longitude = location.longitude
        }
        return content
    }
    
    override func loadData(from data: yTemplateContent) {
        self.title1 = data.text1
        self.title2 = data.text2
        self.footer = data.text3
        self.imageURL = data.url1
        self.url = data.url2
        if let latitude = data.latitude, let longitude = data.longitude {
            self.location = .init(latitude: latitude, longitude: longitude)
        }
    }
}

extension yTemplateCoffee2ViewController: yTemplateLabelDelegate {
    
    func updated(newValue: String?, on label: yTemplateLabel) {
        if label.tag == titleLabel.tag {
            title1 = newValue
        }
        if label.tag == subtitleLabel.tag {
            title2 = newValue
        }
        if label.tag == footerLabel.tag {
            footer = newValue
        }
    }
    
}

extension yTemplateCoffee2ViewController: yTemplateImageDelegate {
    
    func updated(storageURL: URL?, on image: yTemplateImage) {
        if image.tag == self.logoImage.tag {
            imageURL = storageURL
        }
    }
    
}

extension yTemplateCoffee2ViewController: yTemplateButtonMapLocationDelegate {
    
    func openMap(onLocation location: CLLocationCoordinate2D) {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: location, addressDictionary:nil))
        mapItem.name = "Target location"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    func locationSelected(_ location: CLLocationCoordinate2D) {
        self.location = location
    }
    
}

extension yTemplateCoffee2ViewController: yTemplateButtonWebsiteDelegate {
    
    func updated(newValue: URL?, on button: yTemplateButtonWebsite) {
        self.url = newValue
    }
    
    func openWebsite(withURL url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
}
