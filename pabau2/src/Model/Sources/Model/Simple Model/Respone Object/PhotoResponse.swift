import Foundation

public struct PhotoResponse: Codable, Equatable, ResponseStatus {
    
    public let success: Bool
    public let message: String?
    public let total: Int?
    public let photos: [SavedPhoto]?

    public init(success: Bool, total: Int, photos: [SavedPhoto]) {
        self.success = success
        self.total = total
        self.photos = photos
        self.message = nil
    }
    
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case total
        case photos = "employees"
    }
    
}
