//
//  yAdContent.swift
//  Spike
//
//  Created by Cornerstone on 2020-11-12.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import Foundation

class yAdContent: Codable {}

class yTemplateContent: yAdContent {
    
    var templateName: String?
    var text1: String?
    var text2: String?
    var text3: String?
    var url1: URL?
    var url2: URL?
    var latitude: Double?
    var longitude: Double?
    
    override init() {
        super.init()
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        try super.init(from: try container.superDecoder())

        self.templateName = try container.decode(String.self, forKey: .templateName)
        self.text1 = try container.decodeIfPresent(String.self, forKey: .text1)
        self.text2 = try container.decodeIfPresent(String.self, forKey: .text2)
        self.text3 = try container.decodeIfPresent(String.self, forKey: .text3)
        self.url1 = try container.decodeIfPresent(URL.self, forKey: .document1)
        self.url2 = try container.decodeIfPresent(URL.self, forKey: .document2)
        self.latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        self.longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.templateName, forKey: .templateName)
        try container.encodeIfPresent(self.text1, forKey: .text1)
        try container.encodeIfPresent(self.text2, forKey: .text2)
        try container.encodeIfPresent(self.text3, forKey: .text3)
        try container.encodeIfPresent(self.url1, forKey: .document1)
        try container.encodeIfPresent(self.url2, forKey: .document2)
        try container.encodeIfPresent(self.latitude, forKey: .latitude)
        try container.encodeIfPresent(self.longitude, forKey: .longitude)
    }

    fileprivate enum CodingKeys: String, CodingKey {
        case templateName
        case text1
        case text2
        case text3
        case document1
        case document2
        case latitude
        case longitude
    }
    
}
