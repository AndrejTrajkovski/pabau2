import Model
import Foundation

public struct CheckPatient: Equatable, Identifiable {
	public let id: UUID = UUID()
	let patDetails: PatientDetails
	let patForms: [HTMLForm]

	public init (
		patDetails: PatientDetails,
		patForms: [HTMLForm]
	) {
		self.patDetails = patDetails
		self.patForms = patForms
	}
}
