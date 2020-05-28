import SwiftUI
import Model
import ComposableArchitecture
import Util
import Overture

public let checkInMainReducer: Reducer<CheckInViewState, CheckInMainAction, JourneyEnvironment> = .combine(
	metaFormAndStatusReducer.forEach(
		state: \CheckInViewState.forms,
		action: /CheckInMainAction.checkInBody..CheckInBodyAction.updateForm,
		environment: { $0 }),
	checkInBodyReducer.pullback(
		state: \CheckInViewState.self,
		action: /CheckInMainAction.checkInBody,
		environment: { $0 }),
	topViewReducer.pullback(
		state: \CheckInViewState.topView,
		action: /CheckInMainAction.topView,
		environment: { $0 })
)

public enum CheckInMainAction {
	case checkInBody(CheckInBodyAction)
	case complete
	case topView(TopViewAction)
}

struct CheckInMain: View {
	let store: Store<CheckInViewState, CheckInMainAction>
	@ObservedObject var viewStore: ViewStore<CheckInViewState, CheckInMainAction>
	init (store: Store<CheckInViewState, CheckInMainAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	var body: some View {
		VStack (alignment: .center, spacing: 0) {
			TopView(store: self.store
				.scope(state: { $0.topView },
							 action: { .topView($0) }))
			CheckInBody(store: self.store.scope(
				state: { $0 },
				action: { .checkInBody($0) }))
			Spacer()
		}
	}
}

struct FooterButtons: View {
	let store: Store<CheckInViewState, CheckInBodyAction>
	struct State: Equatable {
		let isOnCheckPatient: Bool
	}
	var body: some View {
		WithViewStore(store.scope(
			state: State.init(state:),
			action: { $0 }
		)) { viewStore in
			HStack {
				if viewStore.state.isOnCheckPatient {
					SecondaryButton(Texts.toPatientMode) {
												viewStore.send(.toPatientMode)
					}
				}
				NextButton(store: self.store).frame(maxWidth: 250)
			}
		}
	}
}

extension FooterButtons.State {
	init(state: CheckInViewState) {
		self.isOnCheckPatient = {
			guard let selectedForm = state.selectedForm else { return false }
			return stepType(form: selectedForm.form) == .checkpatient
		}()
	}
}

struct NextButton: View {
	let store: Store<CheckInViewState, CheckInBodyAction>
	struct State: Equatable {
		let index: Int
		let isDisabled: Bool
	}

	var body: some View {
		print("next button body")
		return WithViewStore(store.scope(
			state: State.init(state:),
			action: { $0 })) { viewStore in
			PrimaryButton(Texts.next, isDisabled: viewStore.state.isDisabled) {
				viewStore.send(.didSelectCompleteFormIdx(viewStore.state.index))
			}
			.disabled(viewStore.state.isDisabled)
		}
	}
}

extension NextButton.State {
	init (state: CheckInViewState) {
		print("next button init")
		self.index = state.selectedIndex
		self.isDisabled = !(state.selectedForm?.form.canProceed ?? true)
	}
}
