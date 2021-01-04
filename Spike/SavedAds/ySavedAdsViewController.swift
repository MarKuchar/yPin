//
//  ySavedAdsViewController.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-11-26.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit
import Firebase

class ySavedAdsViewController: UIViewController {
    
    var currentUser = Auth.auth().currentUser!
    var savedAds: [ySavedAd] = []
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = UIConstants.CollecionView.lineSpace
        layout.sectionInset = .init(top: 20, left: 0, bottom: 0, right: 0)
        
        let collView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collView.translatesAutoresizingMaskIntoConstraints = false
        collView.delegate = self
        collView.backgroundColor = .none
        collView.dataSource = self
        collView.register(yTemplateContentCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        return collView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getSaveAds()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        view.backgroundColor = .ybackgroundColor
        
        self.navigationController!.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: "Optima Regular", size: 35)!,
            NSAttributedString.Key.foregroundColor:UIColor.white]
        
        let image = UIImage(named: "Favourites.png")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        self.navigationItem.titleView = imageView
    }
    
    @objc func discardAd(_ btn: UIBarButtonItem) {
        
    }
    
    func setupLayout() {
        self.view.addSubview(self.collectionView)
        self.collectionView.matchParent(padding: UIConstants.CollecionView.viewPadding)
    }
    
    fileprivate func getSaveAds() {
        RepositoryFactory.createUserRepository().fetchSavedAds(userID: currentUser.uid) { (ads) in
            DispatchQueue.main.async {
                self.savedAds = ads
                self.collectionView.reloadData()
            }
        }
    }
    
    fileprivate func openAdWith(id: String) {
        let adRepository = RepositoryFactory.createAdRepository()
        adRepository.get(withId: id) { (ad) in
            guard let contentType = ad.contentType,
                  let content = ad.content,
                  contentType == .template else { return }
            
            let arr = content.split(separator: "|")
            if let subS1 = arr.first,
               let subS2 = arr.last {
                
                let templateName = String.init(subS1)
                let contentId = String.init(subS2)
                
                if let vc = yTemplateViewControllerFactory.creatTemplateViewController(
                    withName: templateName, andState: .onlyRead) {
                    
                    let contentRepository = RepositoryFactory.createTemplateRepository()
                    contentRepository.getContent(withId: contentId) { (templateData) in
                        DispatchQueue.main.async {
                            vc.loadData(from: templateData)
                            vc.showSaveArrow = false
                            vc.currentAdId = id
                            vc.discardAdDelegate = self
                            let navC = UINavigationController(rootViewController: vc)
                            self.navigationController?.present(navC.translucentNavController(), animated: true)
                        }
                    }
                }
            }
        }
    }
}

extension ySavedAdsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionWidth = collectionView.frame.width
        let cellWidth = collectionWidth * 0.48
        let ratio = UIConstants.screenSize.width / UIConstants.screenSize.height
        let cellHeigth = cellWidth / ratio
        return .init(width: cellWidth, height: cellHeigth)
    }
}

extension ySavedAdsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openAdWith(id: savedAds[indexPath.row].docId)
    }
}

extension ySavedAdsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! yTemplateContentCollectionViewCell
        if let adPicture = savedAds[indexPath.row].docPicture {
            cell.image.image = adPicture
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedAds.count
    }
}

extension ySavedAdsViewController: AdDiscard {
    func discardAd(withId: String) {
        RepositoryFactory.createUserRepository().discardSavedAd(userID: currentUser.uid, adId: withId) { success in
            if success, let index = self.savedAds.firstIndex(where: {$0.docId == withId}) {
                DispatchQueue.main.async {
                    self.savedAds.remove(at: index)
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

protocol AdDiscard {
    func discardAd(withId: String)
}
