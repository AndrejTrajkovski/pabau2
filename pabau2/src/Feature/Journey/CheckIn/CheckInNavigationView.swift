import SwiftUI
import ComposableArchitecture
import Model
import CasePaths

public enum CheckInContainerAction {
	case animation(CheckInAnimationAction)
	case main(CheckInMainAction)
}

public enum CheckInAnimationAction {
	case didFinishAnimation
}

public let checkInReducer: Reducer<CheckInContainerState, CheckInContainerAction, JourneyEnvironemnt> = .combine(
	checkInMainReducer.pullback(
					 value: \CheckInContainerState.self,
					 action: /CheckInContainerAction.main,
					 environment: { $0 }),
	fieldsReducer.pullback(
					 value: \CheckInContainerState.self,
					 action: /CheckInContainerAction.main,
					 environment: { $0 })
)

let fieldsReducer: Reducer<CheckInContainerState, CheckInMainAction, JourneyEnvironemnt> =
	indexed(reducer: fieldReducer,
					\CheckInContainerState.selectedTemplate.formStructure.formStructure,
					/CheckInMainAction.form, { $0 })

let fieldReducer: Reducer<CSSField, CheckInFormAction, JourneyEnvironemnt> =
(
	cssClassReducer.pullback(
					 value: \CSSField.cssClass,
					 action: /CheckInFormAction.self,
					 environment: { $0 })
)

let cssClassReducer: Reducer<CSSClass, CheckInFormAction, JourneyEnvironemnt> =
	.combine(
		multipleChoiceReducer.pullback(
					 value: /CSSClass.checkboxes,
					 action: /CheckInFormAction.multipleChoice,
					 environment: { $0 }),
		radioReducer.pullback(
					 value: /CSSClass.radio,
					 action: /CheckInFormAction.radio,
					 environment: { $0 })
)

public struct CheckInNavigationView: View {
	let store: Store<CheckInContainerState, CheckInContainerAction>
	@State var isRunningAnimation: Bool
	public init(store: Store<CheckInContainerState, CheckInContainerAction>) {
		self.store = store
		self._isRunningAnimation = State.init(initialValue: false)
	}

	public var body: some View {
		NavigationView {
			VStack {
				CheckInAnimation(isRunningAnimation: $isRunningAnimation)
				NavigationLink.init(destination:
					CheckInMain(store:
						self.store.scope(value: { $0 },
														 action: { .main($0)}
					)), isActive: $isRunningAnimation, label: { EmptyView() })
			}
		}.navigationViewStyle(StackNavigationViewStyle())
	}
}
