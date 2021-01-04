//
//  AddAdViewController.swift
//  Spike
//
//  Created by Cornerstone on 2020-10-31.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit

class AddAdViewController: UIViewController {

    fileprivate let templateCellId = "template"
    
    let templates = ["yTemplateTest","2","3","4","5","6","7"]
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .vertical
        layout.sectionInset = .init(top: 20, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = UIConstants.CollecionView.lineSpace
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .none
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(yTemplateContentCollectionViewCell.self, forCellWithReuseIdentifier: templateCellId)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.applyBackground(withLayer: .backgroundGrid, andColor: UIConstants.backgroundColor)
        self.view.addSubview(self.collectionView)
        
        self.setupLayout()
        
    }
    
    func setupLayout() {
        self.collectionView.matchParent(padding: UIConstants.CollecionView.viewPadding)
    }
}

extension AddAdViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.templates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: templateCellId, for: indexPath) as! yTemplateContentCollectionViewCell
        cell.fill(self.templates[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO call template based on name
        let templateName = self.templates[indexPath.row]
        print(templateName)
        let template = yTemplateTest2ViewController.init(.editable)
        self.navigationController?.pushViewController(template, animated: true)
    }
    
}

extension AddAdViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionWidth = collectionView.frame.width
        let cellWidth = collectionWidth * 0.48
        let ratio = UIConstants.screenSize.width / UIConstants.screenSize.height
        let cellHeigth = cellWidth / ratio
        return .init(width: cellWidth, height: cellHeigth)
    }
    
}
