import Foundation
import Tagged

public struct FilledFormData: Decodable, Identifiable, Equatable {
	
	public init(templateId: HTMLForm.ID,
				templateName: String,
				templateType: FormType,
				treatmentId: FilledFormData.ID,
				createdAt: Date = Date(),
				epaperImageIds: Int? = nil,
				epaperFormIds: Int? = nil,
				uploadedPhotos: String? = nil) {
		self.templateId = templateId
		self.templateName = templateName
		self.templateType = templateType
		self.treatmentId = treatmentId
		self.createdAt = createdAt
		self.epaperImageIds = epaperImageIds
		self.epaperFormIds = epaperFormIds
		self.uploadedPhotos = uploadedPhotos
	}
	
	public typealias ID = Tagged<FilledFormData, Int>
	
	public var id: Self.ID { treatmentId }
	
	public let templateId: HTMLForm.ID
	public let templateName: String
	public let templateType: FormType
    public let treatmentId: Self.ID
    public let createdAt: Date
    public let epaperImageIds: Int?
    public let epaperFormIds: Int?
    public let uploadedPhotos: String?

    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
		let templateId: FormTemplateInfo.ID
        if let strID = try container.decodeIfPresent(String.self, forKey: .templateId) {
			templateId = FormTemplateInfo.ID.init(rawValue: Int(strID)!)
        } else {
			throw DecodingError.dataCorruptedError(forKey: CodingKeys.templateId, in: container, debugDescription: "Can't parse id for FormData.")
        }
		self.templateId = templateId
        
		self.templateName = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
		
		
		let formType: FormType
        if let type = try? container.decodeIfPresent(String.self, forKey: .type) {
			formType = FormType(rawValue: type) ?? .unknown
        } else {
			formType = .unknown
        }
		self.templateType = formType
		
		if let strID = try container.decodeIfPresent(String.self, forKey: .treatmentId), let id = Int(strID) {
			self.treatmentId = FilledFormData.ID.init(rawValue: id)
		} else {
			throw DecodingError.dataCorruptedError(forKey: CodingKeys.treatmentId, in: container, debugDescription: "Can't parse treatment_id for FormData.")
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
