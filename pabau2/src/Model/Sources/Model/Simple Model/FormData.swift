import Foundation

public struct FormData: Codable, Identifiable, Equatable {
	public var id: FilledForm.ID { treatmentId }
	
	public let templateId: HTMLForm.ID
    public let treatmentId: FilledForm.ID
    public let name: String
    public let type: FormType
    public let createdAt: Date
    public let epaperImageIds: Int?
    public let epaperFormIds: Int?
    public let uploadedPhotos: String?
        
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let strID = try container.decodeIfPresent(String.self, forKey: .templateId), let id = Int(strID) {
			self.templateId = HTMLForm.ID.init(rawValue: strID)
        } else {
			throw DecodingError.dataCorruptedError(forKey: CodingKeys.templateId, in: container, debugDescription: "Can't parse id for FormData.")
        }
        
        if let strID = try container.decodeIfPresent(String.self, forKey: .treatmentId), let id = Int(strID) {
			self.treatmentId = FilledForm.ID.init(rawValue: id)
        } else {
			throw DecodingError.dataCorruptedError(forKey: CodingKeys.treatmentId, in: container, debugDescription: "Can't parse treatment_id for FormData.")
        }
        
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        
        if let type = try? container.decodeIfPresent(String.self, forKey: .type) {
            self.type = FormType(rawValue: type) ?? .unknown
        } else {
            self.type = .unknown
        }
        
        if let date: String = try? container.decode(String.self, forKey: .createdAt) {
            self.createdAt = date.toDate("yyyy-MM-dd HH:mm:ss", region: .local)?.date ?? Date()
        } else {
            self.createdAt = Date()
        }
        
        if let imageIds = try? container.decode(String.self, forKey: .epaperImageIds), let id = Int(imageIds) {
            self.epaperImageIds = id
        } else {
            self.epaperImageIds = nil
        }
        
        if let formIds = try? container.decode(String.self, forKey: .epaperFormIds), let id = Int(formIds) {
            self.epaperFormIds = id
        }else {
            self.epaperFormIds = nil
        }

        self.uploadedPhotos = try container.decodeIfPresent(String.self, forKey: .uploadedPhotos)
            
    }
    
    enum CodingKeys: String, CodingKey {
        case templateId = "id"
        case treatmentId = "treatment_id"
        case name
        case type
        case createdAt = "created_at"
        case epaperImageIds = "epaper_image_ids"
        case epaperFormIds = "epaper_form_ids"
        case uploadedPhotos = "uploaded_photos"
    }
    
}
