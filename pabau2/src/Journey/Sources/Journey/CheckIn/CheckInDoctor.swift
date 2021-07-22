import Foundation
import SwiftUI
import ComposableArchitecture
import Form
import Model

public struct CheckInDoctorState: Equatable {
	public let appointment: Appointment
	let pathway: PathwayTemplate
	var stepStates: [StepState]
	var doctorSelectedIndex: Int
}

public enum CheckInDoctorAction: Equatable {
	case steps(StepsActions)
	case completeJourney(CompleteJourneyBtnAction)
	case stepsView(CheckInAction)
//	case footer(FooterButtonsAction)
}

//aftercareReducer.pullback(
//	state: /MetaForm.aftercare,
//	action: /UpdateFormAction.aftercare,
//	environment: { $0 }),
//photosFormReducer.pullback(
//	state: /MetaForm.photos,
//	action: /UpdateFormAction.photos,
//	environment: { $0 }),
//checkInBodyReducer.pullback(
//	state: \CheckInViewState.self,
//	action: /CheckInMainAction.checkInBody,
//	environment: { $0 }),
