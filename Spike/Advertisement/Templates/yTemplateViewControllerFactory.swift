//
//  yTemplateViewControllerFactory.swift
//  Spike
//
//  Created by Cornerstone on 2020-11-09.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit
import Firebase

enum yTemplateViewControllerFactory {

    static func creatTemplateViewController(withName name:String, andState state: yTemplateState) -> yTemplateViewController? {
        let fullname = name + "ViewController"
        switch fullname {
        case String.init(describing: yTemplateTest2ViewController.self):
            return yTemplateTest2ViewController.init(withState: state)
        case String.init(describing: yTemplateCoffeeViewController.self):
            return yTemplateCoffeeViewController.init(withState: state)
        case String.init(describing: yTemplateCoffee2ViewController.self):
            return yTemplateCoffee2ViewController.init(withState: state)
        default:
            return nil
        }
    }
}

class yTemplateViewController: UIViewController {
    
    var state: yTemplateState!
    
    var currentAdId: String?
    
    private lazy var authUserId = Auth.auth().currentUser!.uid
    
    var discardAdDelegate: AdDiscard!
    
    var showSaveArrow = true;
    var adSaved = false;
    
    var templateFilled = false {
        didSet {
            self.navigationItem.rightBarButtonItem = templateFilled ? self.nextButton : nil
        }
    }
    
    lazy var nextButton: UIBarButtonItem = {
        var btn = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(navigateToAttributesViewController))
        btn.tintColor = .black
        return btn
    }()
    
    lazy var cancelButton: UIBarButtonItem = {
        return .init(barButtonSystemItem: .cancel, target: self, action: #selector(popViewController))
    }()
    
    lazy var saveArrow: UIView = {
        let arrow = UIImageView.init(image: UIImage.init(named: "UpArrowWhite"))
        arrow.dimensions(withSize: .init(width: 100.0, height: 30))
        let label = UILabel.init()
        label.text = "Save"
        label.textAlignment = .center
        label.textColor = .white
        let s = UIStackView.init(arrangedSubviews: [arrow, label])
        s.axis = .vertical
        s.distribution = .equalSpacing
        return s
    }()
    
    lazy var swipeUpSaveGesture = UIPanGestureRecognizer.init(target: self, action: #selector(swipeUpSave))
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.tintColor = .black
        if !self.showSaveArrow, yTemplateState.onlyRead == self.state {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Discard", style: .plain,
                target: self,
                action: #selector(self.discardAd(_:)))
            self.navigationItem.rightBarButtonItem?.tintColor = .red
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSaveArrow()
    }
    
    @objc func swipeUpSave(recognizer : UIPanGestureRecognizer) {
        switch recognizer.state {
            case .began:
                move(baseOnPanRecognizer: recognizer)
            case .changed:
                move(baseOnPanRecognizer: recognizer)
            case .ended:
                moveBack()
            default:
                moveBack()
        }
        
        let yPosition = self.saveArrow.frame.origin.y
        let limit :CGFloat = UIConstants.screenSize.height * 0.6
        if yPosition < limit, !self.adSaved {
            saveAd()
        }
    }
    
    func moveBack() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut) {
            self.saveArrow.frame.origin.y = self.swipeOriginalPosition.y
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func move(baseOnPanRecognizer recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        let dy = self.saveArrow.frame.origin.y + translation.y
        self.saveArrow.frame.origin.y = dy
        
        recognizer.setTranslation(.zero, in: self.view)
    }
    
    func saveAd() {
        guard let id = currentAdId else {
            return
        }
        
        saveArrow.isHidden = true
        sleep(1)
        let screenshot = self.view.screenshot()
        
        RepositoryFactory.createUserRepository().saveNewAd(
            userID: authUserId,
            adId: id, urlImage: screenshot) { (succes, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self.showAlertConfirmation(withTitle: "Attention", andMessage: error.description)
                } else {
                    self.showAlertConfirmation(withTitle: "Attention", andMessage: "Advertisment was saved") {
                        self.adSaved = true
                    }
                }
            }
        }
    }
    
    @objc func discardAd(_ btn: UIBarButtonItem) {
        discardAdDelegate.discardAd(withId: currentAdId!)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.swipeOriginalPosition = self.saveArrow.frame.origin
    }
    
    var swipeOriginalPosition = CGPoint.zero
    
    fileprivate func setupSaveArrow() {
        guard self.showSaveArrow, yTemplateState.onlyRead == self.state else { return }
        self.view.addSubview(self.saveArrow)
        self.saveArrow.translatesAutoresizingMaskIntoConstraints = false
        self.saveArrow.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.saveArrow.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10.0).isActive = true
        self.saveArrow.isUserInteractionEnabled = true
        self.saveArrow.addGestureRecognizer(self.swipeUpSaveGesture)
    }
    
    required init(withState state: yTemplateState) {
        super.init(nibName: nil, bundle: nil)
        self.state = state
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func navigateToAttributesViewController() {
        let vc = yAddAdAttributesViewController.init()
        vc.contentData = self.generateData()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    final func loadData(from template: yTemplateContent, withAd id: String) {
        self.currentAdId = id
        self.loadData(from: template)
    }
    
    func loadData(from: yTemplateContent) {
        fatalError("loadData method must be overrided")
    }
    
    func generateData() -> yTemplateContent {
        fatalError("generateData method must be overrided")
    }
}

extension UIView {
    
    func screenshot() -> UIImage {
        return UIGraphicsImageRenderer(size: bounds.size).image { _ in
            drawHierarchy(in: CGRect(origin: .zero, size: bounds.size), afterScreenUpdates: true)
        }
    }
}

enum yTemplateState {
    case editable
    case onlyRead
}

