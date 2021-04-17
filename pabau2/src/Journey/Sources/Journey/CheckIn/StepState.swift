import Foundation
import Model
import Form

enum StepState: Equatable {
	case consent(HTMLFormParentState)
	case prescription(HTMLFormParentState)
	case treatment(HTMLFormParentState)
	case history(HTMLFormParentState)
	case photos(PhotosState)
	case aftercare(Aftercare)
	case checkPatient(Bool)
	case patientdetails(PatientDetailsParentState)
}

func makeSteps(pathway: Pathway, template: PathwayTemplate, appointment: Appointment) -> [StepState] {
	fatalError()
//	return template.steps.map {
//		let stepEntry = pathway.stepEntries[$0.id] =
//		switch $0.stepType {
//		case .patientdetails:
//			return PatientDetailsParentState(clientId: appointment.customerId,
//											 status: stepEntry.status ?? .pending)
//		case .medicalhistory, .consents, .treatmentnotes, .prescriptions:
//			return fatalError()
//		case .checkpatient:
//			return fatalError()
//		case .photos:
//			return fatalError()
//		case .aftercares:
//			return fatalError()
//		case .patientComplete:
//			return fatalError()
//		}
//	}
}
