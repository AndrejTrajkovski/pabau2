import Model

public struct CheckPatient: Equatable, Identifiable {
	public var id: UUID = UUID()
	let patDetails: PatientDetails
	let patForms: [FormTemplate]
}
