import Foundation
import SwiftUI
import ComposableArchitecture
import Form
import Model

public struct CheckInDoctorState: Equatable {
	public let journey: Journey
	let pathway: PathwayTemplate
	var treatmentNotes: IdentifiedArrayOf<HTMLFormTemplate>
	var treatmentNotesStatuses: [HTMLFormTemplate.ID: Bool]
	var prescriptions: IdentifiedArrayOf<HTMLFormTemplate>
	var prescriptionsStatuses: [HTMLFormTemplate.ID: Bool]
	var aftercare: Aftercare?
	var aftercareStatus: Bool
	var photos: PhotosState
	var doctorSelectedIndex: Int
}

public enum CheckInDoctorAction {
	case aftercare(AftercareAction)
	case photos(PhotosFormAction)
	case completeJourney(CompleteJourneyBtnAction)
	case stepsView(CheckInAction)
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
