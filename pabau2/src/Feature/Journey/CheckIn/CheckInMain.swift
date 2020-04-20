import SwiftUI
import Model
import ComposableArchitecture
import Util

public enum CheckInMainAction {
	case didSelectStepId(Int)
	case closeBtnTap
	case form(Indexed<CheckInFormAction>)
}

func checkInMainReducer(state: inout CheckInContainerState,
												action: CheckInMainAction,
												environment: JourneyEnvironemnt) -> [Effect<CheckInMainAction>] {
	switch action {
	case .closeBtnTap:
		break
	case .didSelectStepId(let id):
		state.selectedStepId = id
	case .form(_):
		break
	}
	return []
}

struct CheckInMain: View {
	let store: Store<CheckInContainerState, CheckInMainAction>
	@ObservedObject var viewStore: ViewStore<CheckInContainerState, CheckInMainAction>
	
	init(store: Store<CheckInContainerState, CheckInMainAction>) {
		self.store = store
		let viewStore = self.store.view
		self.viewStore = viewStore
	}

	var body: some View {
		print("check in main body")
		return VStack (alignment: .center, spacing: 0) {
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
			StepsCollectionView(steps: self.viewStore.value.pathway.steps,
													selectedId: self.viewStore.value.selectedStepId) {
														self.viewStore.send(.didSelectStepId($0))
			}
				.frame(width: 600, alignment: .center)
			Spacer()
			PabauForm(store:
				self.store.scope(value: { $0.selectedTemplate.formStructure.formStructure},
												 action: { $0 }))
		}
		.navigationBarTitle("")
		.navigationBarHidden(true)
	}
}
