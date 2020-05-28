import SwiftUI
import Model
import ComposableArchitecture
import Util
import Overture

public enum CheckInBodyAction {
	case toPatientMode
	case updateForm(Indexed<UpdateFormAction>)
	case didSelectCompleteFormIdx(Int)
	case stepsView(StepsViewAction)
}

let checkInBodyReducer: Reducer<CheckInViewState, CheckInBodyAction, JourneyEnvironment> =
	(
	.combine(
		.init { state, action, _ in
			switch action {
			case .updateForm:
				break
			case .didSelectCompleteFormIdx(let idx):
				state.forms[idx].isComplete = true
				goToNextStep(&state.stepsViewState)
			case .toPatientMode:
				break//handled in navigationReducer
			case .stepsView:
				break
			}
			return .none
		},
		stepsViewReducer.pullback(
			state: \.stepsViewState,
			action: /CheckInBodyAction.stepsView,
			environment: { $0 })
		)
	)

struct CheckInBody: View {

	@EnvironmentObject var keyboardHandler: KeyboardFollower
	let store: Store<CheckInViewState, CheckInBodyAction>
	@ObservedObject var viewStore: ViewStore<CheckInViewState, CheckInBodyAction>
	
	init(store: Store<CheckInViewState, CheckInBodyAction>) {
		print("check in body init")
		self.store = store
		self.viewStore = ViewStore(store)
	}

	var body: some View {
		print("check in main body")
		return GeometryReader { geo in
			VStack(spacing: 8) {
				StepsCollectionView(store:
					self.store.scope(
						state: { $0.stepsViewState}, action: { .stepsView($0) })
				).frame(height: 80)
				Divider()
					.frame(width: geo.size.width)
					.shadow(color: Color(hex: "C1C1C1"), radius: 4, y: 2)
				IfLetStore(self.store
					.scope(state: { $0.selectedForm?.form },
								 action: { .updateForm(Indexed(self.viewStore.state.selectedIndex, $0))
					}), then: FormWrapper.init(store:))
					.padding(.bottom,
									 self.keyboardHandler.keyboardHeight > 0 ? self.keyboardHandler.keyboardHeight : 32)
					.padding([.leading, .trailing, .top], 32)
				Spacer()
				if self.keyboardHandler.keyboardHeight == 0 &&
					!self.viewStore.state.isOnCompleteStep {
					FooterButtons(store: self.store.scope(
						state: { $0 }, action: { $0 }
					))
					.frame(maxWidth: 500)
					.padding(8)
				}
			}	.padding(.leading, 40)
				.padding(.trailing, 40)
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
		let title: String
	}

	var body: some View {
		WithViewStore(store.scope(
			state: State.init(state:),
			action: { $0 })
		) { viewStore in
			PrimaryButton(viewStore.state.title, isDisabled: viewStore.state.isDisabled) {
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
		let isDoctorMode = state.forms.map(pipe(get(\.form), stepType(form:))).allSatisfy(with(.doctor, filterBy))
		let isLastIndex = state.selectedIndex == state.forms.count - 1
		self.title = isDoctorMode && isLastIndex ? Texts.completeJourney : Texts.next
	}
}
