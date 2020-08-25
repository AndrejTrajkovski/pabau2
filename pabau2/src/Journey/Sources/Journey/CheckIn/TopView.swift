import SwiftUI
import Model
import ComposableArchitecture
import Form

let topViewReducer = Reducer<CheckInViewState, TopViewAction, JourneyEnvironment> { state, action, _ in
	switch action {
	case .onXButtonTap:
		state.xButtonActiveFlag = false
	}
	return .none
}

public enum TopViewAction: Equatable {
	case onXButtonTap
}

struct TopView: View {
	let store: Store<CheckInViewState, TopViewAction>

	struct State: Equatable {
		let totalSteps: Int
		let currentStepIdx: Int
		let journey: Journey
		init(state: CheckInViewState) {
			self.totalSteps = state.forms.forms
				.filter { $0.stepType != .patientComplete}
				.flatMap(\.forms)
				.count
			self.currentStepIdx = state.forms.flatSelectedIndex + (state.forms.selectedStep == .patientComplete ? 0 : 1)
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
			XButton(onTap: onClose)
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

struct XButton: View {
	let onTap: () -> Void
	var body: some View {
		Button.init(action: onTap, label: {
			Image(systemName: "xmark")
				.font(Font.light30)
				.foregroundColor(.gray142)
				.frame(width: 30, height: 30)
		})
	}
}
