import Model
import Foundation

public struct CheckPatient: Equatable, Identifiable {
	public let id: UUID = UUID()
	let patDetails: PatientDetails?
	let patForms: [FormTemplate]

	public init (
		patDetails: PatientDetails?,
		patForms: [FormTemplate]
	) {
		self.patDetails = patDetails
		self.patForms = patForms
	}
}
