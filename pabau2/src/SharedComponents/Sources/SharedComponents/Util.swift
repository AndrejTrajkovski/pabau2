import ComposableArchitecture
import SwiftUI
import Util

public struct ErrorViewModifier: ViewModifier {
	@ObservedObject var viewStore: ViewStore<LoadingState, Never>
	public func body(content: Content) -> some View {
		GeometryReaderPatch { geometry in
			ZStack(alignment: .center) {
				switch viewStore.state {
				case .gotError(let error):
					Text("Error: \(error.localizedDescription)")
						.frame(width: geometry.size.width / 2,
							   height: geometry.size.height / 5)
						.background(Color.white)
						.foregroundColor(Color.blue)
						.cornerRadius(20)
				default:
					content
				}
			}
		}
	}
}

//public struct ErrorViewModifier2<State, Action>: ViewModifier {
//	let store: Store<State, Action>
//	@ObservedObject var viewStore: ViewStore<LoadingState, Never>
//
//	init(store: Store<State, Action>,
//		 loadingState: KeyPath<State, LoadingState>) {
//		self.store = store
//		self.viewStore = ViewStore(store.scope(state: { $0[keyPath: loadingState]}).actionless)
//	}
//
//	public func body(content: Content) -> some View {
//		content.errorView(viewStore.state)
//	}
//}

public extension View {
	func errorView<State, Action>(
		store: Store<State, Action>,
		loadingState: KeyPath<State, LoadingState>) -> some View {
		self.modifier(ErrorViewModifier(viewStore: ViewStore(store.scope(state: { $0[keyPath: loadingState]}).actionless)))
	}
}
