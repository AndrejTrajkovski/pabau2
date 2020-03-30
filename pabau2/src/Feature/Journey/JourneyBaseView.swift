import SwiftUI
import Model
import ComposableArchitecture
import CasePaths

public struct JourneyBaseView<Content: View, Action>: View {
	
	let content: Content
	let store: Store<Journey?, Action>
	@ObservedObject var viewStore: ViewStore<State, Action>
	enum State: Equatable {
		case empty
		case profileView(JourneyProfileView.ViewState)
		init (journey: Journey?) {
			if let journey = journey {
				self = .profileView(JourneyProfileView.ViewState.init(journey: journey))
			} else {
				self = .empty
			}
		}
		var profileView: JourneyProfileView.ViewState? {
			if case State.profileView(let viewState) = self {
				return viewState
			} else {
				return nil
			}
		}
	}
	
	init(store: Store<Journey?, Action>,
			 @ViewBuilder content: () -> Content) {
		self.store = store
		self.viewStore = self.store
			.scope(value: State.init,
						 action: { $0 })
			.view
		self.content = content()
	}
	
	public var body: some View {
		Group {
			if (self.viewStore.value.profileView != nil) {
				VStack(spacing: 8) {
					JourneyProfileView(viewState: self.viewStore.value.profileView!)
						.padding()
					content
				}
			} else {
				EmptyView()
			}
		}
	}
}

struct JourneyBaseModifier<Action>: ViewModifier {
	let store: Store<Journey?, Action>
	func body(content: Content) -> some View {
		JourneyBaseView(store: self.store, content: { content })
	}
}

public extension View {

	func journeyBase<Action>(_ store: Store<Journey?, Action>) -> some View {
		self.modifier(JourneyBaseModifier(store: store))
	}
}
