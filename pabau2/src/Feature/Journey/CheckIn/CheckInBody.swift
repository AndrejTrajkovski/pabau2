import SwiftUI
import Model
import ComposableArchitecture
import Util
import Overture

public enum CheckInBodyAction {
	case updateForm(Indexed<UpdateFormAction>)
	case stepsView(StepsViewAction)
	case footer(FooterButtonsAction)
	case completeJourney(CompleteJourneyBtnAction)
}

let checkInBodyReducer: Reducer<CheckInViewState, CheckInBodyAction, JourneyEnvironment> =
	(
	.combine(
		.init { state, action, _ in
			switch action {
			case .updateForm:
				break//binding
			case .stepsView:
				break//handled inline
			case .completeJourney:
				break//handled in checkInMiddleware
			case .footer(_):
				break//handled inline
			}
			return .none
		},
		footerButtonsReducer.pullback(
			state: \.footer,
			action: /CheckInBodyAction.footer,
			environment: { $0 }),
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
		print("check in body body")
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
				if self.keyboardHandler.keyboardHeight == 0
//					&& !self.viewStore.state.isOnCompleteStep
				{
					FooterButtons(store: self.store.scope(
						state: { $0.footer }, action: { .footer($0) }
					))
					.frame(maxWidth: 500)
					.padding(8)
				}
			}	.padding(.leading, 40)
				.padding(.trailing, 40)
		}
	}
}
