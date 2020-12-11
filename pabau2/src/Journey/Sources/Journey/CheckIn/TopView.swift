import SwiftUI
import Model
import ComposableArchitecture
import Form
import Util

// TODO
//state.isDoctorCheckInMainActive = false
public enum TopViewAction: Equatable {
	case onXButtonTap
}

struct TopView: View {
	let store: Store<StepsViewState, TopViewAction>
	
	struct State: Equatable {
		let totalSteps: Int
		let currentStepIdx: Int
		let journey: Journey
		init(state: StepsViewState) {
			self.totalSteps = state.forms.count
			self.currentStepIdx = state.selectedIdx
			self.journey = state.journey
		}
	}
	
	var body: some View {
		WithViewStore(store.scope(state: State.init(state:))) { viewStore in
			TopViewPlain(totalSteps: viewStore.state.totalSteps,
						 currentStepIdx: viewStore.state.currentStepIdx,
						 journey: viewStore.state.journey,
						 onClose: { viewStore.send(.onXButtonTap) }
			)
		}
	}
}

struct TopViewPlain: View {
	let totalSteps: Int
	let currentStepIdx: Int
	let journey: Journey
	let onClose: () -> Void
	var body: some View {
		ZStack {
			XButton(onTouch: onClose)
				.padding()
				.exploding(.topLeading)
			Spacer()
			JourneyProfileView(style: .short,
							   viewState: .init(journey: self.journey))
				.padding()
				.exploding(.top)
			Spacer()
			RibbonView(currentStepIdx: currentStepIdx,
					   totalNumberOfSteps: totalSteps)
				.offset(x: -80, y: -60)
				.exploding(.topTrailing)
		}.frame(height: 168.0)
	}
}
