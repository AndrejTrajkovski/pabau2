import Foundation

public struct Journey: Codable, Identifiable {
	
	public let id: Int
	
	public let appointments: [Appointment]
	
	public let patient: BaseClient
	
	public let pathway: Pathway?
	
	public let employee: Employee
	
	public let patientChecked: PatientStatus?
	
	public let forms: [JourneyForms]?
	
	public let photos: [JourneyPhotos]?
	
	public let postCare: [JourneyPostCare]?
	
	public let media: [Media]?
	public init(id: Int,
							appointments: [Appointment],
							patient: BaseClient,
							pathway: Pathway? = nil,
							employee: Employee,
							patientChecked: PatientStatus? = nil,
							forms: [JourneyForms]? = nil,
							photos: [JourneyPhotos]? = nil,
							postCare: [JourneyPostCare]? = nil,
							media: [Media]? = nil) {
		self.id = id
		self.appointments = appointments
		self.patient = patient
		self.pathway = pathway
		self.employee = employee
		self.patientChecked = patientChecked
		self.forms = forms
		self.photos = photos
		self.postCare = postCare
		self.media = media
	}
	public enum CodingKeys: String, CodingKey {
		case id
		case appointments
		case patient
		case pathway
		case employee
		case patientChecked = "patient_checked"
		case forms
		case photos
		case postCare = "post_care"
		case media
	}
	
}
