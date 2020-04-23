import SwiftUI
import Model
import ComposableArchitecture
import Util

public enum CheckInMainAction {
	case didSelectStepId(Int)
	case closeBtnTap
	case form(Indexed<CheckInFormAction>)
}

let checkInMainReducer = Reducer<CheckInContainerState, CheckInMainAction, JourneyEnvironemnt> { state, action, _ in
	switch action {
	case .closeBtnTap:
		break
	case .didSelectStepId(let id):
		state.selectedStepId = id
	case .form:
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
		let steps: [Step]
		let selectedStepId: Int
		let journey: Journey

		init(state: CheckInContainerState) {
			self.steps = state.pathway.steps
			self.journey = state.journey
			self.selectedStepId = state.selectedStepId
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
				VStack {
				StepsCollectionView(steps: self.viewStore.value.steps,
														selectedId: self.viewStore.value.selectedStepId) {
															self.viewStore.send(.didSelectStepId($0))
				}
				.frame(minWidth: 240, maxWidth: 480, alignment: .center)
				.frame(height: 80)
				PabauForm(store:
					self.store.scope(value: { $0.selectedTemplate.formStructure.formStructure },
													 action: { $0 }))
				}
					.padding(.leading, 40)
					.padding(.trailing, 40)
				Spacer()
				//			.padding(.top, 24)
			}
			.navigationBarTitle("")
			.navigationBarHidden(true)
	}
}
