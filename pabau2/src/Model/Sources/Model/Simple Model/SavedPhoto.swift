import Foundation
import SwiftDate
import Tagged

public struct SavedPhoto: Codable, Identifiable, Equatable, Hashable {
        
    public let id: Int
    public let normalSizePhoto: String?
    public let thumbnail: String?
    public let mediumThumbnail: String?
    public let photoDate: Date
    public let photoTitle: String
    public let photoPosition: String?
    public var normalSizePhotoData: Data?

    public init(id: Int, normalPhotoSize: String?, thumbnail: String?, mediumThumbnail: String?, photoDate: Date, title: String, photoPosition: String? ) {
        self.id = id
        self.normalSizePhoto = normalPhotoSize
        self.thumbnail = thumbnail
        self.mediumThumbnail = mediumThumbnail
        self.photoDate = photoDate
        self.photoTitle = title
        self.photoPosition = photoPosition
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let sId = try? container.decode(String.self, forKey: .id), let id = Int(sId) {
            self.id = id
        } else {
            self.id = 0
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
