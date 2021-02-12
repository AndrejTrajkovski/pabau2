import SwiftUI
import Model
import ComposableArchitecture
import Form
import Util

// TODO
//state.isDoctorCheckInMainActive = false

struct TopView<S: CheckInState, AvatarView: View>: View where S: Equatable {
	let store: Store<S, CheckInAction>
	let avatarView: () -> AvatarView
	struct State: Equatable {
		let totalSteps: Int
		let currentStepIdx: Int
		init(state: S) {
			self.totalSteps = state.stepForms().count
			self.currentStepIdx = state.selectedIdx + 1
		}
	}

	var body: some View {
		WithViewStore(store.scope(state: State.init(state:))) { viewStore in
			TopViewPlain(totalSteps: viewStore.state.totalSteps,
						 currentStepIdx: viewStore.state.currentStepIdx,
						 avatarView: avatarView,
						 onClose: { viewStore.send(.onXTap) }
			)
		}
	}
}

struct TopViewPlain<AvatarView: View>: View {
	let totalSteps: Int
	let currentStepIdx: Int
	let avatarView: () -> AvatarView
	let onClose: () -> Void
	var body: some View {
		ZStack {
			XButton(onTouch: onClose)
				.padding()
				.exploding(.topLeading)
			Spacer()
			avatarView()
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
