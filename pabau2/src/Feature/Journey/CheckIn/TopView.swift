import SwiftUI
import Model
import ComposableArchitecture

let topViewReducer = Reducer<TopViewState, TopViewAction, JourneyEnvironment> { state, action, _ in
	switch action {
	case .onXButtonTap:
		state.xButtonActiveFlag = false
	}
	return .none
}

public struct TopViewState: Equatable {
	var totalSteps: Int
	var completedSteps: Int
	var xButtonActiveFlag: Bool
	var journey: Journey
}

public enum TopViewAction: Equatable {
	case onXButtonTap
}

struct TopView: View {
	let store: Store<TopViewState, TopViewAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			TopViewPlain(totalSteps: viewStore.state.totalSteps,
									 completedSteps: viewStore.state.completedSteps,
									 journey: viewStore.state.journey,
									 onClose: { viewStore.send(.onXButtonTap) })
		}
	}
}

struct TopViewPlain: View {
	let totalSteps: Int
	let completedSteps: Int
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
			RibbonView(completedNumberOfSteps: completedSteps,
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
