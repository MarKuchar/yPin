//
//  SavedAd.swift
//  Spike
//
//  Created by Martin Kuchar on 2020-12-02.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import Foundation
import UIKit

struct ySavedAd: Decodable {
    var docPicture: UIImage?
    var docId: String
}

extension ySavedAd {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: ySavedAdCodingKeys.self)
        let imageString = try values.decode(String.self, forKey: .docPictureUrl)
        if let imageUrl = URL(string: imageString) {
            let imageData = try! Data(contentsOf: imageUrl)
            self.docPicture = UIImage(data: imageData)
        }
        self.docId = try values.decode(String.self, forKey: .docId)
    }
}

enum ySavedAdCodingKeys: String, CodingKey {
    case docId
    case docPictureUrl
}
