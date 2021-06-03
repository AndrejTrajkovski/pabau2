import SwiftUI
import ComposableArchitecture

struct RibbonView<S: CheckInState>: View where S: Equatable {
	
	let store: Store<S, Never>
	
	struct State: Equatable {
		let totalSteps: Int
		let currentStepIdx: Int
		init(state: S) {
			self.totalSteps = state.stepForms().count
			self.currentStepIdx = state.selectedIdx + 1
		}
	}
	
	private let lineWidth: CGFloat = 1
	var body: some View {
		WithViewStore(store.scope(state: State.init(state:))) { viewStore in
			ZStack(alignment: .bottom) {
				RoundedRectangle(cornerRadius: 36.5)
					.stroke(Color(hex: "979797"), lineWidth: lineWidth)
					.overlay(
						RoundedRectangle(cornerRadius: 36.5)
							.fill(Color.deepSkyBlue)
							.shadow(color: Color(hex: "007AFF"), radius: 1, x: 0, y: 5)
					)
					.padding(lineWidth)
				Text("\(viewStore.currentStepIdx)/\(viewStore.totalSteps)")
					.foregroundColor(.white)
					.font(.bold18)
					.alignmentGuide(.bottom, computeValue: { dim in dim[.bottom] + 24 })
			}
			.frame(width: 73, height: 168)
		}
	}
}
