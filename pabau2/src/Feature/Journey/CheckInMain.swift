import SwiftUI
import Model
import ComposableArchitecture

public struct CheckInMainState: Equatable {
	var isCheckedIn: Bool
	var journey: Journey?
	var pathway: Pathway?
	var consents: [FormTemplate]
}

public enum CheckInMainAction {
	case closeBtnTap
}

func checkInMainReducer(state: inout CheckInMainState,
												action: CheckInMainAction,
												environment: JourneyEnvironemnt) -> [Effect<CheckInMainAction>] {
	switch action {
	case .closeBtnTap:
		state.isCheckedIn = false
		state.pathway = nil
		state.journey = nil
	}
	return []
}

struct CheckInMain: View {
	let store: Store<CheckInMainState, CheckInMainAction>
	@ObservedObject var viewStore: ViewStore<CheckInMainState, CheckInMainAction>
	
	init(store: Store<CheckInMainState, CheckInMainAction>) {
		self.store = store
		self.viewStore = self.store.view
	}
	
	var body: some View {
		Button.init("close", action: {
			self.viewStore.send(.closeBtnTap)
		})
	}
}
