//
//  User.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-10-15.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import Foundation
import Firebase

class User : Decodable {
    var displayName: String
    var email: String
    var photoURL: String
    var premium: Bool
}

