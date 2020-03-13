import Foundation
import NonEmpty

public struct Journey: Codable, Identifiable, Equatable, Hashable {
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
	
	public let id: Int
	
	public let appointments: NonEmpty<[Appointment]>
	
	public let patient: BaseClient
	
	public let pathway: Pathway?
	
	public let employee: Employee
	
	public let patientChecked: PatientStatus?
	
	public let forms: [JourneyForms]
	
	public let photos: [JourneyPhotos]
	
	public let postCare: [JourneyPostCare]
	
	public let paid: String
	
	public let media: [Media]?
	public init(id: Int,
							appointments: NonEmpty<[Appointment]>,
							patient: BaseClient,
							pathway: Pathway? = nil,
							employee: Employee,
							patientChecked: PatientStatus? = nil,
							forms: [JourneyForms],
							photos: [JourneyPhotos],
							postCare: [JourneyPostCare],
							media: [Media]? = nil,
							paid: String) {
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
		self.paid = paid
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
		case paid
	}
}
