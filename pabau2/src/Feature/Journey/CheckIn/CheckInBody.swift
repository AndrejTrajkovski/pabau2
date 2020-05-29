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
	case completeJourney(CompleteJourneyBtnAction)
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
			case .completeJourney(_):
				break//handled in checkInMiddleware
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
						state: { $0.footer }, action: { $0 }
					))
					.frame(maxWidth: 500)
					.padding(8)
				}
			}	.padding(.leading, 40)
				.padding(.trailing, 40)
		}
	}
}
