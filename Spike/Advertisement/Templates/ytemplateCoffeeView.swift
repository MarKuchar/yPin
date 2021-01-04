//
//  YtemplateCoffeeView.swift
//  Spike
//
//  Created by Melisa Garcia on 2020-11-26.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit

class yTemplateCoffeeViewController: yTemplateViewController {

    @IBOutlet var title1Label: yTemplateLabel!
    
    @IBOutlet var title2Label: yTemplateLabel!
    
    @IBOutlet var footerLabel: yTemplateLabel!
    
    @IBOutlet var logoImage: yTemplateImage!
    
    var title1: String? = nil {
        didSet {
            title1Label?.text = title1
            checkTemplateFilled()
        }
    }

    var title2: String? = nil {
        didSet {
            title2Label?.text = title2
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
    
    func checkTemplateFilled() {
        templateFilled = self.title1 != nil && self.title2 != nil && self.footer != nil && self.imageURL != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title1Label.setup(
            withTemplateVC: self,
            andDelegate: self,
            editable: self.state! == .editable,
            initialValue: self.title1)

        self.title2Label.setup(
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
    }

    override func generateData() -> yTemplateContent {
        let content = yTemplateContent.init()
        content.templateName = "yTemplateCoffee"
        content.text1 = self.title1
        content.text2 = self.title2
        content.text3 = self.footer
        content.url1 = self.imageURL
        return content
    }
    
    override func loadData(from data: yTemplateContent) {
        self.title1 = data.text1
        self.title2 = data.text2
        self.footer = data.text3
        self.imageURL = data.url1
    }
}

extension yTemplateCoffeeViewController: yTemplateLabelDelegate {
    
    func updated(newValue: String?, on label: yTemplateLabel) {
        if label.tag == title1Label.tag {
            title1 = newValue
        }
        if label.tag == title2Label.tag {
            title2 = newValue
        }
        if label.tag == footerLabel.tag {
            footer = newValue
        }
    }
    
}

extension yTemplateCoffeeViewController: yTemplateImageDelegate {
    func updated(storageURL: URL?, on image: yTemplateImage) {
        if image.tag == logoImage.tag {
            imageURL = storageURL
        }
    }
}
