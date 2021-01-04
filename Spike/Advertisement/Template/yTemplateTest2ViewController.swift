//
//  yTemplateTest2ViewController.swift
//  Spike
//
//  Created by Cornerstone on 2020-11-08.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit

class yTemplateTest2ViewController: UIViewController {

    @IBOutlet var templateLabel: UILabel!
    
    var templateName: String? = nil
    var state: yTemplateState!
    
    init(_ state:yTemplateState) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupGestureRecognizer()
        
        // Do any additional setup after loading the view.
        self.templateLabel.text = templateName ?? "Unkown"
        
        
    }
    
    func setupGestureRecognizer() {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapTemplateLabel))
        self.templateLabel.addGestureRecognizer(tap)
        self.templateLabel.isUserInteractionEnabled = true
    }

    @objc func tapTemplateLabel() {
        print("tapTemplateLabel")
        
        let alert = UIAlertController.init(title: "Input", message: "Enter Template Name", preferredStyle: .alert)
        
        alert.addTextField { (tf) in
            tf.placeholder = "Enter here"
        }
        
        alert.addAction(.init(title: "OK", style: .default, handler: { (a) in
            let tf = alert.textFields![0]
            self.templateLabel.text = tf.contents ?? self.templateLabel.text
        }))
        
        alert.addAction(.init(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

struct yTemplateTest2Data: Codable {
    var templateName: String?
}

enum yTemplateState {
    case editable
    case onlyRead
}
