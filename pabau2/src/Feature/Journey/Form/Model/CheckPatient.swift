import Model

public struct CheckPatient: Equatable {
	let patDetails: PatientDetails
	let patForms: [FormTemplate]
}
