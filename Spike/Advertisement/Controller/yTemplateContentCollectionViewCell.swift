//
//  YImportContentCollectionViewCell.swift
//  Spike
//
//  Created by Cornerstone on 2020-11-07.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit

class yTemplateContentCollectionViewCell: UICollectionViewCell {
    
    lazy var image: UIImageView = {
        let placeholder = UIImage.init(systemName: "plus")
        let iv = UIImageView.init(image: placeholder)
        iv.backgroundColor = .systemGray5
        iv.layer.cornerRadius = UIConstants.CollecionView.cellCornerRadius
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.contentView.addSubview(self.image)
        self.image.matchParent()
    }
    
    func fill(_ templateName: String) {
        // TODO load imagem from template
    }
    
}
