import Foundation
import NonEmpty

<<<<<<< HEAD
public struct Journey: Codable, Identifiable, Equatable, Hashable {

	public static var defaultEmpty: Journey {
		Journey(
            id: -1,
						appointments: NonEmpty.init(Appointment.defaultEmpty),
            patient: BaseClient.init(id: 0, firstName: "", lastName: "", dOB: "", email: "", avatar: "", phone: ""), employee: Employee.defaultEmpty, forms: [], photos: [], postCare: [], paid: ""
        )
	}

	public static func == (lhs: Self, rhs: Self) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	public let id: Int

	public let appointments: NonEmpty<[Appointment]>

	public let patient: BaseClient

	public let pathway: Pathway?

	public let employee: Employee

	public let patientChecked: PatientStatus?

	public let forms: [JourneyForms]?

	public let photos: [SavedPhoto]?

	public let postCare: [JourneyPostCare]?

	public let paid: String?

	public let media: [Media]?
    
    public init(
        id: Int,
							appointments: NonEmpty<[Appointment]>,
							patient: BaseClient,
							pathway: Pathway? = nil,
							employee: Employee,
							patientChecked: PatientStatus? = nil,
							forms: [JourneyForms],
							photos: [SavedPhoto],
							postCare: [JourneyPostCare],
							media: [Media]? = nil,
        paid: String
    ) {
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

public extension Journey {
	var servicesString: String {
		appointments
			.map { $0.service }
            .compactMap { $0?.name }
			.reduce("", +)
	}
}
=======
//public struct Journey: Codable, Identifiable, Equatable, Hashable {
//
//	public static var defaultEmpty: Journey {
//		Journey(id: -1,
//						appointments: NonEmpty.init(Appointment.defaultEmpty),
//						patient: BaseClient.init(id: 0, firstName: "", lastName: "", dOB: "", email: "", avatar: "", phone: ""), employee: Employee.defaultEmpty, forms: [], photos: [], postCare: [], paid: "")
//	}
//
//	public static func == (lhs: Self, rhs: Self) -> Bool {
//		return lhs.id == rhs.id
//	}
//
//	public func hash(into hasher: inout Hasher) {
//		hasher.combine(id)
//	}
//
//	public let id: Int
//
//	public let appointments: NonEmpty<[Appointment]>
//
//	public let patient: BaseClient
//
//	public let pathway: Pathway?
//
//	public let employee: Employee
//
//	public let patientChecked: PatientStatus?
//
//	public let forms: [JourneyForms]?
//
//	public let photos: [SavedPhoto]?
//
//	public let postCare: [JourneyPostCare]?
//
//	public let paid: String?
//
//	public let media: [Media]?
//	public init(id: Int,
//							appointments: NonEmpty<[Appointment]>,
//							patient: BaseClient,
//							pathway: Pathway? = nil,
//							employee: Employee,
//							patientChecked: PatientStatus? = nil,
//							forms: [JourneyForms],
//							photos: [SavedPhoto],
//							postCare: [JourneyPostCare],
//							media: [Media]? = nil,
//							paid: String) {
//		self.id = id
//		self.appointments = appointments
//		self.patient = patient
//		self.pathway = pathway
//		self.employee = employee
//		self.patientChecked = patientChecked
//		self.forms = forms
//		self.photos = photos
//		self.postCare = postCare
//		self.media = media
//		self.paid = paid
//	}
//	public enum CodingKeys: String, CodingKey {
//		case id
//		case appointments
//		case patient
//		case pathway
//		case employee
//		case patientChecked = "patient_checked"
//		case forms
//		case photos
//		case postCare = "post_care"
//		case media
//		case paid
//	}
//}
//
//public extension Journey {
//	var servicesString: String {
//		appointments
//			.map { $0.service }
//            .compactMap { $0?.name }
//			.reduce("", +)
//	}
//}
>>>>>>> master
