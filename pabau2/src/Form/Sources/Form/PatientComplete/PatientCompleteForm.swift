import SwiftUI
import Util
import ComposableArchitecture
import Model

public let patientCompleteReducer = Reducer<StepStatus, PatientCompleteAction, FormEnvironment> { state, action, _ in
	switch action {
	case .didTouchComplete:
		state = .completed
	}
	return .none
}

public enum PatientCompleteAction {
	case didTouchComplete
}

public struct PatientCompleteForm: View {
	let store: Store<StepStatus, PatientCompleteAction>

	public init(store: Store<StepStatus, PatientCompleteAction>) {
		self.store = store
	}

	public var body: some View {
		print("PatientCompleteForm body")
		return WithViewStore(store) { viewStore in
			VStack(spacing: 32) {
				Image("ico-journey-complete")
					.frame(width: 163, height: 247)
				Text(Texts.journeyCompleteTitle)
					.font(.semibold22)
				Text(Texts.journeyCompleteDesc)
					.font(.regular16)
				Button.init(action: {
					viewStore.send(.didTouchComplete)
				},
				label: {
					Text("Complete")
						.frame(minWidth: 0, maxWidth: .infinity)
						.frame(height: 50)
						.foregroundColor(Color.white)
						.background(Color.accentColor)
						.cornerRadius(10)
						.font(Font.system(size: 16.0, weight: .bold))
						.frame(width: 290)
				})
			}.padding(32)
		}
	}
}
