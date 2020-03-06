//
// JourneyPhotos.swift

import Foundation


public struct JourneyPhotos: Codable, Identifiable {

    public let id: Int
    public let url: String?
    
    public init(id: Int, url: String? = nil) {
        self.id = id
        self.url = url
    }
    public enum CodingKeys: String, CodingKey { 
        case id
        case url
    }

}
