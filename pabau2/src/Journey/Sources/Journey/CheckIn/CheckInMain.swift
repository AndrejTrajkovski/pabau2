import SwiftUI
import Model
import ComposableArchitecture
import Util
import Overture
import CasePaths
import Form

public let checkInMainReducer: Reducer<CheckInViewState, CheckInMainAction, JourneyEnvironment> = .combine(
	formTemplateReducer.pullbackCp(
		state: /MetaForm.template,
		action: /UpdateFormAction.template,
		environment: { $0 }),
	patientCompleteReducer.pullbackCp(
		state: /MetaForm.patientComplete,
		action: /UpdateFormAction.patientComplete,
		environment: { $0 }),
	patientDetailsReducer.pullbackCp(
		state: /MetaForm.patientDetails,
		action: /UpdateFormAction.patientDetails,
		environment: { $0 }),
	aftercareReducer.pullbackCp(
		state: /MetaForm.aftercare,
		action: /UpdateFormAction.aftercare,
		environment: { $0 }),
	photosFormReducer.pullbackCp(
		state: /MetaForm.photos,
		action: /UpdateFormAction.photos,
		environment: { $0 }),
	checkInBodyReducer.pullback(
		state: \CheckInViewState.self,
		action: /CheckInMainAction.checkInBody,
		environment: { $0 }),
	topViewReducer.pullback(
		state: \CheckInViewState.self,
		action: /CheckInMainAction.topView,
		environment: { $0 })
)

public enum CheckInMainAction {
	case checkInBody(CheckInBodyAction)
	case complete
	case topView(TopViewAction)
}

struct CheckInMain: View {
	let store: Store<CheckInViewState, CheckInMainAction>

	var body: some View {
		VStack (spacing: 0) {
			TopView(store: self.store
						.scope(state: { $0 },
							   action: { .topView($0) }))
			CheckInBody(store: self.store.scope(
							state: { $0 },
							action: { .checkInBody($0) }))
			Spacer()
		}
	}
}
