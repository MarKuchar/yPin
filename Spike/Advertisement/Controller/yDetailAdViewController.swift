//
//  yDetailAdViewController.swift
//  Spike
//
//  Created by Cornerstone on 2020-11-15.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit

class yDetailAdViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let adRepository = RepositoryFactory.createAdRepository()
        adRepository.get(withId: "zVaxWUj3YogiuRXDdJWY") { (ad) in
            guard let contentType = ad.contentType,
                  let content = ad.content,
                  contentType == .template else { return }

            let arr = content.split(separator: "|")
            if let subS1 = arr.first, 
               let subS2 = arr.last {
                
                let templateName = String.init(subS1)
                let contentId = String.init(subS2)
                
                if let vc = yTemplateViewControllerFactory.creatTemplateViewController(withName: templateName, andState: .onlyRead) {
                    
                    let contentRepository = RepositoryFactory.createTemplateRepository()
                    contentRepository.getContent(withId: contentId) { (templateData) in
                        DispatchQueue.main.async {
                            vc.loadData(from: templateData)
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            }
        }
    }
}
