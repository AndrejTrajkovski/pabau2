import Foundation
import SwiftUI
import ComposableArchitecture
import Form

public struct CheckInDoctorState: Equatable {
	let journey: Journey
	let pathway: Pathway
	var treatmentNotes: IdentifiedArrayOf<FormTemplate>
	var treatmentNotesStatuses: [FormTemplate.ID: Bool]
	var prescriptions: IdentifiedArrayOf<FormTemplate>
	var prescriptionsStatuses: [FormTemplate.ID: Bool]
	var aftercare: Aftercare?
	var aftercareStatus: Bool
	var photos: PhotosState
	var doctorSelectedIndex: Int
}

public enum CheckInDoctorAction {
	case aftercare(AftercareAction)
	case photos(PhotosFormAction)
	case completeJourney(CompleteJourneyBtnAction)
	case stepsView(StepsViewAction)
//	case footer(FooterButtonsAction)
}

//aftercareReducer.pullbackCp(
//	state: /MetaForm.aftercare,
//	action: /UpdateFormAction.aftercare,
//	environment: { $0 }),
//photosFormReducer.pullbackCp(
//	state: /MetaForm.photos,
//	action: /UpdateFormAction.photos,
//	environment: { $0 }),
//checkInBodyReducer.pullback(
//	state: \CheckInViewState.self,
//	action: /CheckInMainAction.checkInBody,
//	environment: { $0 }),
