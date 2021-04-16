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

func makeSteps(pathway: Pathway, template: PathwayTemplate) -> [StepState] {
	fatalError()
//	template.steps.map {
//		switch $0.stepType {
//		case .patientdetails:
//
//		case .medicalhistory:
//			
//		case .consents:
//			
//		case .checkpatient:
//			
//		case .treatmentnotes:
//			
//		case .prescriptions:
//			
//		case .photos:
//			
//		case .aftercares:
//			
//		case .patientComplete:
//			
//		}
//	}
}
