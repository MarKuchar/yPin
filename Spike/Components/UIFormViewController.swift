//
//  UIFormViewController.swift
//  Spike
//
//  Created by Cornerstone on 2020-10-31.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import UIKit

class UIFormViewController: UIViewController {
    
    var activeTextField : UITextField!
    
    typealias ValidationResponse = (valid: Bool, error: String?)
    typealias ValidationFunction = () -> ValidationResponse
    
    var dicValidations: [String: [ValidationFunction]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        super.viewWillDisappear(animated)
    }

    @objc func keyboardWillShow(notification:NSNotification?) {
        guard let activeTextField = self.activeTextField else { return }
        guard let keyboardValue = notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardSize = keyboardValue.cgRectValue.size
        self.view.frame.origin.y = 0
        let keyboardYPosition = self.view.frame.size.height - keyboardSize.height
        var activeTextFieldYPosition = activeTextField.frame.origin.y + activeTextField.bounds.height
        var parent = activeTextField.superview
        while parent != nil, parent != view {
            activeTextFieldYPosition += parent!.frame.origin.y
            parent = parent!.superview
        }
        if keyboardYPosition < activeTextFieldYPosition {
            self.view.frame.origin.y = self.view.frame.origin.y - keyboardSize.height + 30
        }
    }

    @objc func keyboardWillHide(notification:NSNotification?) {
        self.view.frame.origin.y = 0
    }
    
    func validateForm(sucessed: () -> Void, failed: (([String]) -> Void)? = nil) {
        var errors = [String]()
        for (_, validations) in dicValidations {
            for validation in validations {
                let response = validation()
                if !response.valid {
                    errors.append(response.error ?? "Unkown error")
                }
            }
        }
        
        if errors.isEmpty {
            sucessed()
        } else {
            if let failed = failed {
                failed(errors)
            }
        }
    }
    
    func add(toIdentitier id: String, validation: @escaping ValidationFunction) {
        // validations -> a copy of the array
        // array in swift is struct (not ref)
        var validations = dicValidations[id]
        if validations == nil {
            validations = [ValidationFunction]()
        }
        validations!.append(validation)
        dicValidations[id] = validations
    }
}

extension UIFormViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }
}



