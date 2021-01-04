//
//  Ad.swift
//  Spike
//
//  Created by Cornerstone on 2020-10-17.
//  Copyright © 2020 Martin Kuchar. All rights reserved.
//

import Foundation
import Firebase

struct Ad: Encodable {
    init(uid: String? = nil, ownerUid: String? = nil, content: String? = nil, contentType: yContentType, adType: yAdType? = nil, active: Bool, priority: Bool? = false, creationDate: Date? = nil, startDate: Date? = nil, endDate: Date? = nil, geoLocation: GeoLocation? = nil) {
        self.uid = uid
        self.ownerUid = ownerUid
        self.content = content
        self.contentType = contentType
        self.adType = adType
        self.active = active
        self.priority = priority
        self.creationDate = creationDate
        self.startDate = startDate
        self.endDate = endDate
        self.geoLocation = geoLocation
    }
    
    init(ownerUid: String? = nil, content: String? = nil, contentType: yContentType, adType: yAdType? = nil, active: Bool = false,
         priority: Bool = false, creationDate: Date? = nil, startDate: Date? = nil, endDate: Date? = nil, geoLocation: GeoLocation? = nil) {
        self.init(uid: nil, ownerUid: ownerUid, content: content, contentType: contentType, adType: adType, active: active,
                  priority: priority, creationDate: creationDate, startDate: startDate, endDate: endDate, geoLocation: geoLocation)
    }
    
    var uid: String?
    var ownerUid: String?
    var content: String?
//    var contentType: yContentType
    var contentType: yContentType?
    var adType: yAdType?
    var active: Bool
    var priority: Bool?
    var creationDate: Date?
    var startDate: Date?
    var endDate: Date?
    var geoLocation: GeoLocation?

}

extension Ad : Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.uid = try values.decode(String.self, forKey: .uid)
        self.ownerUid = try values.decodeIfPresent(String.self, forKey: .ownerUid)
        self.content = try values.decodeIfPresent(String.self, forKey: .content)
//        self.contentType = try values.decode(yContentType.self, forKey: .contentType)
        self.contentType = try values.decodeIfPresent(yContentType.self, forKey: .contentType)
        self.adType = try values.decodeIfPresent(yAdType.self, forKey: .adType)
        self.active = try values.decode(Bool.self, forKey: .active)
        self.priority = try values.decodeIfPresent(Bool.self, forKey: .priority)
        if values.contains(.creationDate),
           let dateContainer = try? values.nestedContainer(keyedBy: dateCodingKey.self, forKey: .creationDate),
           let sec = try dateContainer.decodeIfPresent(Int32.self, forKey: .seconds) {
            self.creationDate = Date.init(timeIntervalSince1970: TimeInterval.init(sec))
        }
        if values.contains(.startDate),
           let timestampDate = try values.decodeIfPresent(Timestamp.self, forKey: .startDate) {
            self.startDate = timestampDate.dateValue()
        }
        if values.contains(.endDate),
           let timestampDate = try values.decodeIfPresent(Timestamp.self, forKey: .endDate) {
//           let dateContainer = try? values.nestedContainer(keyedBy: dateCodingKey.self, forKey: .endDate),
//           let sec = try dateContainer.decodeIfPresent(Int32.self, forKey: .seconds) {
            self.endDate = timestampDate.dateValue()
        }
        self.geoLocation = try values.decodeIfPresent(GeoLocation.self, forKey: .geoLocation)
    }
}

enum CodingKeys: String, CodingKey {
    case uid
    case ownerUid
    case content
    case contentType
    case adType
    case active
    case priority
    case creationDate
    case startDate
    case endDate
    case geoLocation
}

enum dateCodingKey: String, CodingKey {
    case seconds = "_seconds"
    case nanosecond = "_nanoseconds"
}

enum yContentType: String, Codable {
    case template
}

enum yAdType: String, Codable, CaseIterable {
    case pin = "Pin"
    case beer = "Beer"
    case clothes = "Clothes"
    case coffee = "Coffee"
    case entertainment = "Entertainment"
    case restaurant = "Restaurant"
    case sports = "Sports"
    case favorites = "Favorites"
    
    func getFilePath() -> String {
        return "art.scnassets/\(self.rawValue).scn"
    }
}
