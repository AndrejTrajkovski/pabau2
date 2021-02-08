//
// Form.swift

import Foundation

/** Object representing a form, without the field values. Meant to be returned when the form patient_status is needed but not the form field values. Is a superclass of Form, which contains the field values. */
public struct FormData: Codable, Identifiable, Equatable {
    
    public let id: Int
    public let treatmentId: Int
    public let name: String
    public let type: FormType
    public let createdAt: Date
    public let epaperImageIds: Int?
    public let epaperFormIds: Int?
    public let uploadedPhotos: String?
    
    init(id: Int, treatmentId: Int, name: String, type: FormType, createdAt: Date, epaperImageIds: Int? = nil, epaperFormIds: Int? = nil, uploadedPhotos: String? = nil ) {
        self.id = id
        self.treatmentId = treatmentId
        self.name = name
        self.type = type
        self.createdAt = createdAt
        self.epaperFormIds = epaperFormIds
        self.epaperImageIds = epaperImageIds
        self.uploadedPhotos = uploadedPhotos
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let strID = try container.decodeIfPresent(String.self, forKey: .id), let id = Int(strID) {
            self.id = id
        } else {
            self.id = 0
        }
        
        if let strID = try container.decodeIfPresent(String.self, forKey: .treatmentId), let id = Int(strID) {
            self.treatmentId = id
        } else {
            self.treatmentId = 0
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
        case id
        case treatmentId = "treatment_id"
        case name
        case type
        case createdAt = "created_at"
        case epaperImageIds = "epaper_image_ids"
        case epaperFormIds = "epaper_form_ids"
        case uploadedPhotos = "uploaded_photos"
    }
    
}

extension FormData {
    static let mockFilledConsents = [
        FormData(id: 1, treatmentId: 2, name: "Hello there", type: .consent, createdAt: Date()),
        FormData(id: 2, treatmentId: 1, name: "General Kenobi", type: .treatment, createdAt: Date())
    ]
    
    static let mockFilledTreatments = [
        FormData(id: 1, treatmentId: 2, name: "Hello there", type: .consent, createdAt: Date()),
        FormData(id: 2, treatmentId: 1, name: "General Kenobi", type: .treatment, createdAt: Date())
    ]
    
    static let mockFIlledPrescriptions = [
        FormData(id: 1, treatmentId: 2, name: "Hello there", type: .consent, createdAt: Date()),
        FormData(id: 2, treatmentId: 1, name: "General Kenobi", type: .treatment, createdAt: Date())
    ]
}
