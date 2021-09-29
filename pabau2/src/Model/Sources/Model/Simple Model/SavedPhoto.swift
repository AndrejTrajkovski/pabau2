import Foundation
import SwiftDate
import Tagged

public struct SavedPhoto: Codable, Identifiable, Equatable, Hashable {
        
    public let id: Tagged<SavedPhoto, Int>
    public let normalSizePhoto: String?
    public let thumbnail: String?
    public let mediumThumbnail: String?
    public let photoDate: Date
    public let photoTitle: String
    public let photoPosition: String?
    public var normalSizePhotoData: Data?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let stringId = try? container.decode(String.self, forKey: .id),
           let toIntID = Int(stringId) {
            self.id = Self.ID(rawValue: toIntID)
        } else if let intId = try? container.decode(Int.self, forKey: .id) {
            self.id = Self.ID(rawValue: intId)
        } else {
            throw DecodingError.dataCorruptedError(forKey: CodingKeys.id, in: container, debugDescription: "Id is not string or int")
        }

        if let date: String = try? container.decode(String.self, forKey: .photoDate) {
            self.photoDate = date.toDate("dd/MM/yyyy", region: .local)?.date ?? Date()
        } else {
            self.photoDate = Date()
        }

        self.normalSizePhoto = try container.decode(String.self, forKey: .normalSizePhoto)
        self.thumbnail = try container.decode(String.self, forKey: .thumbnail)
        self.mediumThumbnail = try container.decode(String.self, forKey: .mediumThumbnail)
        self.photoTitle = try container.decode(String.self, forKey: .photoTitle)
        self.photoPosition = try container.decodeIfPresent(String.self, forKey: .photoPosition)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case normalSizePhoto = "normal_size"
        case thumbnail
        case mediumThumbnail = "medium_thumbnail"
        case photoDate = "photo_date"
        case photoTitle = "photo_title"
        case photoPosition = "photo_position"
    }
}

extension SavedPhoto {
    
//    public init(imageModel: ImageModel) {
//        self.id = imageModel.id
//    }
}
