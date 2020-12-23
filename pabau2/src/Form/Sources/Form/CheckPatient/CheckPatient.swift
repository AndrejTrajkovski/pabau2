import Model
import Foundation

public struct CheckPatient: Equatable, Identifiable {
	public let id: UUID = UUID()
	let patDetails: PatientDetails
	let patForms: [HTMLFormTemplate]

	public init (
		patDetails: PatientDetails,
		patForms: [HTMLFormTemplate]
	) {
		self.patDetails = patDetails
		self.patForms = patForms
	}
}
