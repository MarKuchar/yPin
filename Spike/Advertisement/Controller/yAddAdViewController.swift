//
//  AddAdViewController.swift
//  Spike
//
//  Created by Cornerstone on 2020-10-31.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit

class yAddAdViewController: UIViewController {

    fileprivate let uploadCellId = "upload"
    fileprivate let templateCellId = "template"
    
    var templates = [yTemplate]()
    
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
        collectionView.register(yUploadContentCollectionViewCell.self, forCellWithReuseIdentifier: uploadCellId)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backButtonTitle = ""
        
        let image = UIImage(named: "Template.png")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        self.navigationItem.titleView = imageView
        view.backgroundColor = .ybackgroundColor
        
        self.setupLayout()
        
        self.fetchTemplates()
    }
    
    func fetchTemplates() {
        DispatchQueue.global(qos: .background).async {
            let templateRepo = RepositoryFactory.createTemplateRepository()
            templateRepo.fetchTemplates { (result) in
                self.templates = result
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    @objc func popViewController() {
        self.navigationController?.popViewControllerFromTop()
    }
    
    func setupLayout() {
        self.view.addSubview(self.collectionView)
        self.collectionView.matchParent(padding: UIConstants.CollecionView.viewPadding)
    }

}

extension yAddAdViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 2
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if section == 0 {
//            return 1
//        }
        return self.templates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if indexPath.section == 0 {
//            return self.collectionView.dequeueReusableCell(withReuseIdentifier: uploadCellId, for: indexPath) as! yUploadContentCollectionViewCell
//        }
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: templateCellId, for: indexPath) as! yTemplateContentCollectionViewCell
        cell.fill(template: self.templates[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if indexPath.section == 0 {
//            // TODO present upload file http/pdf/jpeg
//            self.navigationController?.present(UIViewController.init(), animated: true)
//            return
//        }
        let template = self.templates[indexPath.row]
        if let template = yTemplateViewControllerFactory.creatTemplateViewController(withName: template.name, andState: .editable) {
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem?.tintColor = .black
            self.navigationController?.pushViewController(template, animated: true)
        } else {
            self.showAlertConfirmation(withTitle: "Attention", andMessage: "Template is temporarily unavailable")
        }
    }
}

extension yAddAdViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionWidth = collectionView.frame.width
//        if indexPath.section == 0 {
//            return .init(width: collectionWidth * 0.8, height: UIConstants.Button.buttonIconSize.height)
//        }
        let cellWidth = collectionWidth * 0.48
        let ratio = UIConstants.screenSize.width / UIConstants.screenSize.height
        let cellHeigth = cellWidth / ratio
        return .init(width: cellWidth, height: cellHeigth)
    }
    
}
