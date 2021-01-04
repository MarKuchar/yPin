//
//  YImportContentCollectionViewCell.swift
//  Spike
//
//  Created by Cornerstone on 2020-11-07.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit
import FirebaseUI

class yTemplateContentCollectionViewCell: UICollectionViewCell {
    
    let placeholder = UIImage.init(systemName: "plus")
    
    lazy var image: UIImageView = {
        let iv = UIImageView.init(image: placeholder)
        iv.backgroundColor = .white
        iv.layer.cornerRadius = UIConstants.CollecionView.cellCornerRadius
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        self.contentView.backgroundColor = .black
        self.contentView.layer.cornerRadius = UIConstants.CollecionView.cellCornerRadius
        self.clipsToBounds = true
        self.contentView.addSubview(self.image)
        self.image.matchParent(padding: .init(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0))
    }
    
    func fill(template: yTemplate) {
        // TODO load imagem from template
        
        let templateRepo = RepositoryFactory.createTemplateRepository()
        
        templateRepo.fetchTemplateImageRef(withDocId: template.pictureDocId) { (stoRef) in
            DispatchQueue.main.async {
                self.image.sd_setImage(with: stoRef, placeholderImage: self.placeholder)
            }
        }
    }
}
