//
//  yTemplateTest2ViewController.swift
//  Spike
//
//  Created by Cornerstone on 2020-11-08.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit

class yTemplateTest2ViewController: yTemplateViewController {

    @IBOutlet var templateLabel: yTemplateLabel!
    
    var templateName: String? = nil {
        didSet {
            self.templateLabel?.text = templateName ?? "Unkown"
            self.checkTemplateFilled()
        }
    }
    
    var testName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.applyBackground(withLayer: .backgroundGrid)
        
        self.templateLabel.text = templateName ?? "Unkown"
        self.templateLabel.setup(
            withTemplateVC: self,
            andDelegate: self,
            editable: self.state! == .editable,
            initialValue: self.testName)
    }
    
    override func loadData(from data: yTemplateContent) {
        self.templateName = data.text1
    }
    
    override func generateData() -> yTemplateContent {
        let data = yTemplateContent.init()
        data.templateName = "yTemplateTest2"
        data.text1 = self.templateName
        return data
    }
    
    func checkTemplateFilled()  {
        self.templateFilled = self.templateName != nil
    }

}

extension yTemplateTest2ViewController: yTemplateLabelDelegate {
    
    func updated(newValue: String?, on label: yTemplateLabel) {
        if label.tag == self.templateLabel.tag {
            self.templateName = newValue
        }
    }
    
}
