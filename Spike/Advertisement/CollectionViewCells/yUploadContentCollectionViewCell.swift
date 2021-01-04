//
//  yUploadContentCollectionViewCell.swift
//  Spike
//
//  Created by Cornerstone on 2020-11-09.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit

class yUploadContentCollectionViewCell: UICollectionViewCell {
    
    lazy var button: UIButton = {
        let bt = UIButton.init()
        bt.setTitle("Upload file", for: .normal)
        bt.backgroundColor = .darkGray
        bt.layer.cornerRadius = UIConstants.CollecionView.cellCornerRadius
        bt.isUserInteractionEnabled = false
        return bt
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        self.contentView.addSubview(self.button)
        self.button.matchParent()
    }
    
}
