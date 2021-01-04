//
//  UITextView+Additions.swift
//  GreenWanderer
//
//  Created by Martin Kuchar on 2020-09-16.
//

import UIKit

extension UITextField {
  var contents: String? {
    guard
      let text = text?.trimmingCharacters(in: .whitespaces),
      !text.isEmpty
      else {
        return nil
    }

    return text
  }
}
