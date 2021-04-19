import Foundation
import Model
import Form

enum StepState: Equatable {
	case htmlForm(HTMLFormParentState)
	case photos(PhotosState)
	case aftercare(Aftercare)
	case checkPatient(Bool)
	case patientdetails(PatientDetailsParentState)
}

func makeSteps(pathway: Pathway, template: PathwayTemplate, appointment: Appointment) -> [StepState] {
	fatalError()
//	return template.steps.map {
//		let stepEntry = pathway.stepEntries[$0.id]
//		switch $0.stepType {
//		case .patientdetails:
//			let pds = PatientDetailsParentState(clientId: appointment.customerId,
//												status: stepEntry?.status ?? .pending)
//			return .patientdetails(pds)
//		case .medicalhistory, .consents, .treatmentnotes, .prescriptions:
//			let htmlfs = HTMLFormParentState(templateId: stepEntry?.formTemplateId!,
//												templateName: "TODO: GET FROM API",
//												type: $0.stepType.formType(),
//												clientId: appointment.customerId,
//												filledFormId: stepEntry?.formEntryId)
//			return .htmlForm(htmlfs)
//		case .checkpatient:
//			return .checkPatient(false)
//		case .photos:
//			return .photos(PhotosState())
//		case .aftercares:
//			return .aftercare(Aftercare())
//		case .patientComplete:
//			return .checkPatient(false)
//		}
//	}
}
