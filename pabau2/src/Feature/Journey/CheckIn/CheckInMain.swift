import SwiftUI
import Model
import ComposableArchitecture
import Util

public enum CheckInMainAction {
	case closeBtnTap
	case patient(StepFormsAction)
}

let checkInMainReducer = Reducer<CheckInContainerState, CheckInMainAction, JourneyEnvironemnt> { state, action, _ in
	switch action {
	case .closeBtnTap:
		//handled elsewhere
		break
	case .patient(_):
		break
	}
	return []
}

struct CheckInMain: View {
	let store: Store<CheckInContainerState, CheckInMainAction>
	@ObservedObject var viewStore: ViewStore<State, CheckInMainAction>

	init(store: Store<CheckInContainerState, CheckInMainAction>) {
		self.store = store
		self.viewStore = self.store
			.scope(value: State.init(state:),
						 action: { $0 })
			.view
	}

	struct State: Equatable {
		let journey: Journey

		init(state: CheckInContainerState) {
			self.journey = state.journey
		}
	}

	var body: some View {
		print("check in main body")
		return
			VStack (alignment: .center, spacing: 0) {
				ZStack {
					Button.init(action: { self.viewStore.send(.closeBtnTap) }, label: {
						Image(systemName: "xmark")
							.font(Font.light30)
							.foregroundColor(.gray142)
							.frame(width: 30, height: 30)
					})
						.padding()
						.frame(minWidth: 0, maxWidth: .infinity,
									 minHeight: 0, maxHeight: .infinity,
									 alignment: .topLeading)
					Spacer()
					JourneyProfileView(style: .short,
														 viewState: .init(journey: self.viewStore.value.journey))
						.padding()
						.frame(minWidth: 0, maxWidth: .infinity,
									 minHeight: 0, maxHeight: .infinity,
									 alignment: .top)
					Spacer()
					RibbonView(completedNumberOfSteps: 1, totalNumberOfSteps: 4)
						.offset(x: -80, y: -60)
						.frame(minWidth: 0, maxWidth: .infinity,
									 minHeight: 0, maxHeight: .infinity,
									 alignment: .topTrailing)
				}.frame(height: 168.0)
				StepForms(store:
					self.store.scope(
						value: { $0.patient },
						action: { .patient($0) }))
				Spacer()
			}
			.navigationBarTitle("")
			.navigationBarHidden(true)
	}
}

struct StepFormsState {
	var steps: [Step]
	var selectedStepId: Int
	var templates: [FormTemplate]
	var currentFields: [CSSField]
}

public enum StepFormsAction {
	case didUpdateFields([CSSField])
	case didSelectStepId(Int)
}

let stepFormsReducer = Reducer<StepFormsState, StepFormsAction, JourneyEnvironemnt> { state, action, env in
	switch action {
		case .didUpdateFields(let fields):
		state.currentFields = fields
		case .didSelectStepId(let id):
		state.selectedStepId = id
	}
	return []
}

struct StepForms: View {
	
	let store: Store<StepFormsState, StepFormsAction>
	@ObservedObject var viewStore: ViewStore<StepFormsState, StepFormsAction>
	
	init(store: Store<StepFormsState, StepFormsAction>) {
		self.store = store
		self.viewStore = store.view(removeDuplicates: ==)
	}
	
	var body: some View {
		VStack {
			StepsCollectionView(steps: self.viewStore.value.steps,
													selectedId: self.viewStore.value.selectedStepId) {
														self.viewStore.send(.didSelectStepId($0))
		}
		.frame(minWidth: 240, maxWidth: 480, alignment: .center)
		.frame(height: 80)
			PabauFormWrap(store: self.store)
		}
			.padding(.leading, 40)
			.padding(.trailing, 40)
	}
}
