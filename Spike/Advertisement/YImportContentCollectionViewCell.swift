//
//  YImportContentCollectionViewCell.swift
//  Spike
//
//  Created by Cornerstone on 2020-11-07.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit

class yTemplateContentCollectionViewCell: UICollectionViewCell {

    fileprivate let importLabel = "Import Content"
    fileprivate let updateLabel = "Update Content"
    
    lazy var button: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.isUserInteractionEnabled = false
        btn.layer.cornerRadius = UIConstants.Button.cornerRadius
        btn.setTitle(importLabel, for: .normal)
        btn.backgroundColor = .red
        return btn
    }()
    
    var containsContent = false {
        didSet {
            if containsContent {
                self.button.setTitle(updateLabel, for: .normal)
                self.button.backgroundColor = .cyan
            } else {
                self.button.setTitle(importLabel, for: .normal)
                self.button.backgroundColor = .red
            }
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.contentView.addSubview(self.button)
        self.button.matchParent()
    }
}
