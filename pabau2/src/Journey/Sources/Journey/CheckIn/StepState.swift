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
