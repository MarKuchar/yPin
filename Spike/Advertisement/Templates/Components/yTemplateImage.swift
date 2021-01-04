//
//  yTemplateImagem.swift
//  Spike
//
//  Created by Cornerstone on 2020-11-26.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit
import MobileCoreServices;

class yTemplateImage: UIImageView {

    weak var templateVC: yTemplateViewController?
    weak var delegate: yTemplateImageDelegate?
    
    let placeholder = UIImage.init(systemName: "plus")
    
    var editable: Bool = false {
        didSet {
            updateComponent()
        }
    }
    
    var imageId:String? = nil {
        didSet{
            updateComponent()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestureRecognizer()
        setupComponent()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGestureRecognizer()
        setupComponent()
    }

    func updateComponent() {
        if self.editable {
            self.layer.cornerRadius = UIConstants.TemplateComponent.editableCornerRadius
            self.layer.backgroundColor = UIConstants.TemplateComponent.editableColor
            self.image = placeholder
            self.isUserInteractionEnabled = true
        } else {
            self.backgroundColor = .none
            self.layer.cornerRadius = .zero
            self.isUserInteractionEnabled = false
        }
    }
    
    fileprivate func setupGestureRecognizer() {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapTemplateImage))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }
    
    let indicator: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView.init(style: .medium)
        indicatorView.hidesWhenStopped = true
        indicatorView.isHidden = true
        return indicatorView
    }()
    
    fileprivate func setupComponent() {
        self.addSubview(self.indicator)
        self.indicator.centerXYin(self)
    }
    
    func setup(
        withTemplateVC vc: yTemplateViewController,
        andDelegate delegate: yTemplateImageDelegate,
        editable: Bool,
        initialValue: URL? = nil) {
        self.templateVC = vc
        self.delegate = delegate
        self.editable = editable
        guard let initialURL = initialValue else {
            return
        }
        RepositoryFactory.createTemplateRepository().downloadImage(from: initialURL) { image in
            if let image = image {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
    
    lazy var imagePickerDelegate = ImagePickerDelegate.init(yImage: self)
    
    lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = ["public.image"]
        imagePicker.delegate = imagePickerDelegate
        return imagePicker
    }()
    
    @objc func tapTemplateImage() {
        self.templateVC?.present(imagePicker, animated: true)
    }
    
}

class ImagePickerDelegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var yImage: yTemplateImage!
    
    init(yImage: yTemplateImage) {
        super.init()
        self.yImage = yImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        DispatchQueue.main.async {
            self.yImage.image = self.yImage.placeholder
            self.yImage.indicator.isHidden = false
            self.yImage.indicator.startAnimating()
        }
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            let templateRep = RepositoryFactory.createTemplateRepository();
            templateRep.upload(image: pickedImage) { url in
                DispatchQueue.main.async {
                    self.yImage.image = pickedImage
                    self.yImage.indicator.stopAnimating()
                    self.yImage.delegate?.updated(storageURL: url, on: self.yImage)
                }
            }
        }
        self.yImage.delegate?.updated(storageURL: nil, on: self.yImage)
        picker.dismiss(animated: true, completion: nil)
    }
}

protocol yTemplateImageDelegate: class, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func updated(storageURL: URL?, on image: yTemplateImage)
}
