import SwiftUI
import ComposableArchitecture
import Util
import Model

public func passChangedReducer(state: inout Navigation, action: PassChangedAction, environment: LoginEnvironment) -> [Effect<PassChangedAction>] {
	switch action {
	case .signInTapped:
		state.login?.removeAll(where: { $0 == .passChangedScreen })
		state.login?.removeAll(where: { $0 == .resetPassScreen })
		state.login?.removeAll(where: { $0 == .checkEmailScreen })
		state.login?.removeAll(where: { $0 == .forgotPassScreen })
		return []
	}
}

public enum PassChangedAction: Equatable {
	case signInTapped
}

public struct PasswordChanged: View {
	let store: Store<Navigation, PassChangedAction>
	@ObservedObject var viewStore: ViewStore<Navigation, PassChangedAction>
	init (store: Store<Navigation, PassChangedAction>) {
		self.store = store
		self.viewStore = self.store.view
	}
	let content = WalkthroughContentContent(title: Texts.passwordChanged,
																					description: Texts.passwordChangedDesc,
																					imageTitle: "illu-password-changed")
	public var body: some View {
		WalkthroughContentAndButton(content: content,
																btnTitle: Texts.signIn,
																btnAction: { self.viewStore.send(.signInTapped) })
		.navigationBarBackButtonHidden(true)
	}
}
